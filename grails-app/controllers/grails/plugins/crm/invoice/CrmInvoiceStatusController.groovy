/*
 * Copyright 2013 Goran Ehrsson.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package grails.plugins.crm.invoice

import org.springframework.dao.DataIntegrityViolationException

import javax.servlet.http.HttpServletResponse

class CrmInvoiceStatusController {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    static navigation = [
            [group: 'admin',
                    order: 870,
                    title: 'crmInvoiceStatus.label',
                    action: 'index'
            ]
    ]

    def selectionService
    def crmOrderService

    def domainClass = CrmInvoiceStatus

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        def baseURI = new URI('gorm://crmInvoiceStatus/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                grails.plugins.crm.core.WebUtils.setTenantData(request, 'crmInvoiceStatusQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        try {
            def result = selectionService.select(uri, params)
            [crmInvoiceStatusList: result, crmInvoiceStatusTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmInvoiceStatusList: [], crmInvoiceStatusTotal: 0, selection: uri]
        }
    }

    def create() {
        def crmInvoiceStatus = crmOrderService.createInvoiceStatus(params)
        switch (request.method) {
            case 'GET':
                return [crmInvoiceStatus: crmInvoiceStatus]
            case 'POST':
                if (!crmInvoiceStatus.save(flush: true)) {
                    render view: 'create', model: [crmInvoiceStatus: crmInvoiceStatus]
                    return
                }

                flash.success = message(code: 'crmInvoiceStatus.created.message', args: [message(code: 'crmInvoiceStatus.label', default: 'Order Status'), crmInvoiceStatus.toString()])
                redirect action: 'list'
                break
        }
    }

    def edit() {
        switch (request.method) {
            case 'GET':
                def crmInvoiceStatus = domainClass.get(params.id)
                if (!crmInvoiceStatus) {
                    flash.error = message(code: 'crmInvoiceStatus.not.found.message', args: [message(code: 'crmInvoiceStatus.label', default: 'Order Status'), params.id])
                    redirect action: 'list'
                    return
                }

                return [crmInvoiceStatus: crmInvoiceStatus]
            case 'POST':
                def crmInvoiceStatus = domainClass.get(params.id)
                if (!crmInvoiceStatus) {
                    flash.error = message(code: 'crmInvoiceStatus.not.found.message', args: [message(code: 'crmInvoiceStatus.label', default: 'Order Status'), params.id])
                    redirect action: 'list'
                    return
                }

                if (params.version) {
                    def version = params.version.toLong()
                    if (crmInvoiceStatus.version > version) {
                        crmInvoiceStatus.errors.rejectValue('version', 'crmInvoiceStatus.optimistic.locking.failure',
                                [message(code: 'crmInvoiceStatus.label', default: 'Order Status')] as Object[],
                                "Another user has updated this Type while you were editing")
                        render view: 'edit', model: [crmInvoiceStatus: crmInvoiceStatus]
                        return
                    }
                }

                crmInvoiceStatus.properties = params

                if (!crmInvoiceStatus.save(flush: true)) {
                    render view: 'edit', model: [crmInvoiceStatus: crmInvoiceStatus]
                    return
                }

                flash.success = message(code: 'crmInvoiceStatus.updated.message', args: [message(code: 'crmInvoiceStatus.label', default: 'Order Status'), crmInvoiceStatus.toString()])
                redirect action: 'list'
                break
        }
    }

    def delete() {
        def crmInvoiceStatus = domainClass.get(params.id)
        if (!crmInvoiceStatus) {
            flash.error = message(code: 'crmInvoiceStatus.not.found.message', args: [message(code: 'crmInvoiceStatus.label', default: 'Order Status'), params.id])
            redirect action: 'list'
            return
        }

        if (isInUse(crmInvoiceStatus)) {
            render view: 'edit', model: [crmInvoiceStatus: crmInvoiceStatus]
            return
        }

        try {
            def tombstone = crmInvoiceStatus.toString()
            crmInvoiceStatus.delete(flush: true)
            flash.warning = message(code: 'crmInvoiceStatus.deleted.message', args: [message(code: 'crmInvoiceStatus.label', default: 'Order Status'), tombstone])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmInvoiceStatus.not.deleted.message', args: [message(code: 'crmInvoiceStatus.label', default: 'Order Status'), params.id])
            redirect action: 'edit', id: params.id
        }
    }

    private boolean isInUse(CrmInvoiceStatus type) {
        def count = CrmOrder.countByInvoiceStatus(type)
        def rval = false
        if (count) {
            flash.error = message(code: "crmInvoiceStatus.delete.error.reference", args:
                    [message(code: 'crmInvoiceStatus.label', default: 'Order Status'),
                            message(code: 'crmOrder.label', default: 'Orders'), count],
                    default: "This {0} is used by {1} {2}")
            rval = true
        }
        return rval
    }

    def moveUp(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def prev = domainClass.createCriteria().list([sort: 'orderIndex', order: 'desc']) {
                lt('orderIndex', sort)
                maxResults 1
            }?.find { it }
            if (prev) {
                domainClass.withTransaction { tx ->
                    target.orderIndex = prev.orderIndex
                    prev.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }

    def moveDown(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def next = domainClass.createCriteria().list([sort: 'orderIndex', order: 'asc']) {
                gt('orderIndex', sort)
                maxResults 1
            }?.find { it }
            if (next) {
                domainClass.withTransaction { tx ->
                    target.orderIndex = next.orderIndex
                    next.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }
}
