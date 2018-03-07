package grails.plugins.crm.invoice

import grails.converters.JSON
import grails.plugins.crm.core.CrmEmbeddedAddress
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.WebUtils
import grails.plugins.crm.core.CrmValidationException
import grails.plugins.crm.invoice.CrmInvoiceQueryCommand
import grails.transaction.Transactional
import org.springframework.dao.DataIntegrityViolationException

import javax.servlet.http.HttpServletResponse
import java.util.concurrent.TimeoutException

/**
 * Invoice CRUD Controller.
 */
class CrmInvoiceController {

    static allowedMethods = [create: ["GET", "POST"], edit: ["GET", "POST"], delete: "POST"]

    def crmSecurityService
    def selectionService
    def crmInvoiceService
    def crmContactService
    def crmTagService
    def userTagService

    def crmProductService // optional

    def index() {
        // If any query parameters are specified in the URL, let them override the last query stored in session.
        def cmd = new CrmInvoiceQueryCommand()
        def query = params.getSelectionQuery()
        bindData(cmd, query ?: WebUtils.getTenantData(request, 'crmInvoiceQuery'))
        [cmd: cmd]
    }

    def list() {
        def baseURI = new URI('bean://crmInvoiceService/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                WebUtils.setTenantData(request, 'crmInvoiceQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 10, 100)

        def result
        try {
            result = selectionService.select(uri, params)
            if (result.totalCount == 1 && params.view != 'list') {
                // If we only got one record, show the record immediately.
                redirect action: "show", params: selectionService.createSelectionParameters(uri) + [id: result.head().ident()]
            } else {
                [crmInvoiceList: result, crmInvoiceTotal: result.totalCount, selection: uri]
            }
        } catch (Exception e) {
            flash.error = e.message
            [crmInvoiceList: [], crmInvoiceTotal: 0, selection: uri]
        }
    }

    def clearQuery() {
        WebUtils.setTenantData(request, 'crmInvoiceQuery', null)
        redirect(action: 'index')
    }

    @Transactional
    def create() {
        def crmInvoice = new CrmInvoice(ref: params.ref, invoice: new CrmEmbeddedAddress(), delivery: new CrmEmbeddedAddress(), invoiceDate: new java.sql.Date(System.currentTimeMillis()))

        if (request.post) {
            try {
                crmInvoice = crmInvoiceService.saveInvoice(crmInvoice, params)
            } catch (CrmValidationException e) {
                crmInvoice = e[0]
            }
            if (!crmInvoice.hasErrors()) {
                def currentUser = crmSecurityService.currentUser
                event(for: "crmInvoice", topic: "created", fork: false, data: [id: crmInvoice.id, tenant: crmInvoice.tenantId, user: currentUser?.username])
                flash.success = message(code: 'crmInvoice.created.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), crmInvoice.toString()])
                redirect(action: "show", id: crmInvoice.id)
                return
            }
        } else {
            bindData(crmInvoice, params, [include: CrmInvoice.BIND_WHITELIST])
            bindData(crmInvoice.invoice, params, 'invoice')
            bindData(crmInvoice.delivery, params, 'delivery')
        }

        def metadata = [:]
        metadata.invoiceStatusList = crmInvoiceService.listInvoiceStatus(null).findAll { it.enabled }
        if (crmInvoice.invoiceStatus && !metadata.invoiceStatusList.contains(crmInvoice.invoiceStatus)) {
            metadata.invoiceStatusList << crmInvoice.invoiceStatus
        }
        metadata.paymentTermList = crmInvoiceService.listPaymentTerm(null).findAll { it.enabled }
        if (crmInvoice.paymentTerm && !metadata.paymentTermList.contains(crmInvoice.paymentTerm)) {
            metadata.paymentTermList << crmInvoice.paymentTerm
        }

        return [crmInvoice: crmInvoice, metadata: metadata]
    }

    @Transactional
    def copy(Long id, boolean credit) {
        def original = crmInvoiceService.getInvoice(id)
        if (!original) {
            flash.error = message(code: 'crmInvoice.not.found.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), id])
            redirect(action: "index")
            return
        }

        def crmInvoice = original.copy(credit)

        def metadata = [:]
        metadata.invoiceStatusList = crmInvoiceService.listInvoiceStatus(null).findAll { it.enabled }
        if (crmInvoice.invoiceStatus && !metadata.invoiceStatusList.contains(crmInvoice.invoiceStatus)) {
            metadata.invoiceStatusList << crmInvoice.invoiceStatus
        }
        metadata.paymentTermList = crmInvoiceService.listPaymentTerm(null).findAll { it.enabled }
        if (crmInvoice.paymentTerm && !metadata.paymentTermList.contains(crmInvoice.paymentTerm)) {
            metadata.paymentTermList << crmInvoice.paymentTerm
        }
        metadata.paymentStatusList = CrmInvoice.PAYMENT_STATUS_LIST
        metadata.vatList = getVatOptions()
        metadata.allProducts = getProductList(crmInvoice)

        render view: 'create', model: [crmInvoice: crmInvoice, metadata: metadata]
    }

    @Transactional
    def edit(Long id) {
        def crmInvoice = CrmInvoice.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmInvoice) {
            flash.error = message(code: 'crmInvoice.not.found.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), id])
            redirect(action: "index")
            return
        }
        if (request.post) {
            if (params.int('version') != null && crmInvoice.version > params.int('version')) {
                crmInvoice.errors.rejectValue("version", "crmInvoice.optimistic.locking.failure",
                        [message(code: 'crmInvoice.label', default: 'Invoice')] as Object[],
                        "Another user has updated this invoice while you were editing")
            } else {
                def ok = false
                try {
                    crmInvoice = crmInvoiceService.saveInvoice(crmInvoice, params)
                    ok = !crmInvoice.hasErrors()
                } catch (CrmValidationException e) {
                    crmInvoice = (CrmInvoice) e[0]
                } catch (Exception e) {
                    // Re-attach object to this Hibernate session to avoid problems with uninitialized associations.
                    if (!crmInvoice.isAttached()) {
                        crmInvoice.discard()
                        crmInvoice.attach()
                    }
                    log.warn("Failed to save crmInvoice@$id", e)
                    flash.error = e.message
                }

                if (ok) {
                    def currentUser = crmSecurityService.currentUser
                    event(for: "crmInvoice", topic: "updated", fork: false, data: [id: crmInvoice.id, tenant: crmInvoice.tenantId, user: currentUser?.username])
                    flash.success = message(code: 'crmInvoice.updated.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), crmInvoice.toString()])
                    redirect(action: "show", id: crmInvoice.id)
                    return
                }
            }
        }

        def metadata = [:]
        metadata.invoiceStatusList = crmInvoiceService.listInvoiceStatus(null).findAll { it.enabled }
        if (crmInvoice.invoiceStatus && !metadata.invoiceStatusList.contains(crmInvoice.invoiceStatus)) {
            metadata.invoiceStatusList << crmInvoice.invoiceStatus
        }
        metadata.paymentTermList = crmInvoiceService.listPaymentTerm(null).findAll { it.enabled }
        if (crmInvoice.paymentTerm && !metadata.paymentTermList.contains(crmInvoice.paymentTerm)) {
            metadata.paymentTermList << crmInvoice.paymentTerm
        }
        metadata.paymentStatusList = CrmInvoice.PAYMENT_STATUS_LIST
        metadata.vatList = getVatOptions()
        metadata.allProducts = getProductList(crmInvoice)

        return [crmInvoice: crmInvoice, metadata: metadata]
    }

    def delete(Long id) {
        def crmInvoice = CrmInvoice.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmInvoice) {
            flash.error = message(code: 'crmInvoice.not.found.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), id])
            redirect(action: "list")
            return
        }

        try {
            def tombstone = crmInvoice.toString()
            crmInvoice.delete(flush: true)
            flash.warning = message(code: 'crmInvoice.deleted.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), tombstone])
            redirect(action: "index")
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmInvoice.not.deleted.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), id])
            redirect(action: "edit", id: id)
        }
    }

    def show(Long id) {
        def crmInvoice = CrmInvoice.findByIdAndTenantId(id, TenantUtils.tenant)
        if (crmInvoice) {
            return [crmInvoice: crmInvoice, customer: crmInvoice.getCustomer(), selection: params.getSelectionURI()]
        } else {
            flash.error = message(code: 'crmInvoice.not.found.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), id])
            redirect(action: "index")
        }
    }

    def export() {
        def user = crmSecurityService.getUserInfo()
        def ns = params.ns ?: 'crmInvoice'
        if (request.post) {
            def filename = message(code: 'crmInvoice.label', default: 'Invoice')
            try {
                def topic = params.topic ?: 'export'
                def result = event(for: ns, topic: topic,
                        data: params + [user: user, tenant: TenantUtils.tenant, locale: request.locale, filename: filename]).waitFor(60000)?.value
                if (result?.file) {
                    try {
                        WebUtils.inlineHeaders(response, result.contentType, result.filename ?: ns)
                        WebUtils.renderFile(response, result.file)
                    } finally {
                        result.file.delete()
                    }
                    return null // Success
                } else {
                    flash.warning = message(code: 'crmInvoice.export.nothing.message', default: 'Nothing was exported')
                }
            } catch (TimeoutException te) {
                flash.error = message(code: 'crmInvoice.export.timeout.message', default: 'Export did not complete')
            } catch (Exception e) {
                log.error("Export event throwed an exception", e)
                flash.error = message(code: 'crmInvoice.export.error.message', default: 'Export failed due to an error', args: [e.message])
            }
            redirect(action: "index")
        } else {
            def uri = params.getSelectionURI() ?: new URI('bean://crmInvoiceService/list?id=0')
            def layouts = event(for: ns, topic: (params.topic ?: 'exportLayout'),
                    data: [tenant: TenantUtils.tenant, username: user.username, uri: uri]).waitFor(10000)?.values?.flatten()
            [layouts: layouts, selection: uri]
        }
    }

    private List getVatOptions() {
        getVatList().collect {
            [label: "${it}%", value: (it / 100).doubleValue()]
        }
    }

    private List<Number> getVatList() {
        grailsApplication.config.crm.currency.vat.list ?: [0]
    }

    private List getProductList(final CrmInvoice crmInvoice) {
        def result
          // TODO Remove dependency on crmProductService and use synchronous application event to request product list.
        if (crmProductService != null) {
            result = crmProductService.list().collect{[id: it.number, label: it.toString()]}
        } else {
            def tenant = crmInvoice?.tenantId ?: TenantUtils.tenant
            def user = crmSecurityService.getUserInfo()
            result = event(for: 'crmInvoice', topic: 'productList',
                    data: [id: crmInvoice?.id, tenant: tenant, username: user.username]).waitFor(10000)?.values?.flatten()
        }
        for(item in crmInvoice?.items) {
            if(! result.find{it.id == item.productId}) {
                result << [id: item.productId, label: item.productName]
            }
        }
        result.sort{it.id}
    }

    def addItem(Long id) {
        def crmInvoice = id ? crmInvoiceService.getInvoice(id) : null
        def count = crmInvoice?.items?.size() ?: 0
        def vat = grailsApplication.config.crm.currency.vat.default ?: 0
        def metadata = [:]
        metadata.vatList = getVatOptions()
        metadata.allProducts = getProductList(crmInvoice)

        def item = new CrmInvoiceItem(invoice: crmInvoice, orderIndex: count + 1, quantity: 1, unit: 'st', price: 0, discount: 0, vat: vat)
        render template: 'item', model: [row: 0, bean: item, metadata: metadata]
    }

    def deleteItem(Long id) {
        def item = CrmInvoiceItem.get(id)
        if (item) {
            def crmInvoice = item.invoice
            if (crmInvoice.tenantId == TenantUtils.tenant) {
                try {
                    item.delete(flush: true)
                    render 'true'
                } catch (Exception e) {
                    log.error("Failed to delete CrmInvoiceItem($id)", e)
                    render 'false'
                }
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN)
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
    }

    def createFavorite(Long id) {
        def crmInvoice = crmInvoiceService.getInvoice(id)
        if (!crmInvoice) {
            flash.error = message(code: 'crmInvoice.not.found.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), id])
            redirect action: 'index'
            return
        }
        userTagService.tag(crmInvoice, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)

        redirect(action: 'show', id: params.id)
    }

    def deleteFavorite(Long id) {
        def crmInvoice = crmInvoiceService.getInvoice(id)
        if (!crmInvoice) {
            flash.error = message(code: 'crmInvoice.not.found.message', args: [message(code: 'crmInvoice.label', default: 'Invoice'), id])
            redirect action: 'index'
            return
        }
        userTagService.untag(crmInvoice, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)
        redirect(action: 'show', id: id)
    }

    def autocompleteCustomer(String a, String q) {
        def result
        if (crmContactService != null) {
            if (!a) {
                a = 'name'
            }
            result = crmContactService.list([(a): q], [max: 20]).collect {
                def name = [it.name, it.email, it.telephone, it.number].findAll { it }.join(', ')
                def addr = it.address ?: [:]
                [name, it.id, it.number, it.fullName, it.firstName, it.lastName, it.email, it.telephone,
                        addr.address1, addr.address2, addr.address3, addr.postalCode, addr.city]
            }
        } else {
            result = []
        }
        WebUtils.noCache(response)
        render result as JSON
    }

    def autocompleteInvoiceStatus() {
        def result = crmInvoiceService.listInvoiceStatus(params.remove('term'), params).collect { it.toString() }
        WebUtils.defaultCache(response)
        render result as JSON
    }

    def autocompletePaymentTerm() {
        def result = crmInvoiceService.listPaymentTerm(params.remove('term'), params).collect { it.toString() }
        WebUtils.defaultCache(response)
        render result as JSON
    }

    def autocompleteTags() {
        params.offset = params.offset ? params.int('offset') : 0
        if (params.limit && !params.max) params.max = params.limit
        params.max = Math.min(params.max ? params.int('max') : 25, 100)
        def result = crmTagService.listDistinctValue(CrmInvoice.name, params.remove('q'), params)
        WebUtils.defaultCache(response)
        render result as JSON
    }

}
