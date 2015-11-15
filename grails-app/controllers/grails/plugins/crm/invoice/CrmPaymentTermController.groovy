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

class CrmPaymentTermController {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    static navigation = [
            [group: 'admin',
                    order: 880,
                    title: 'crmPaymentTerm.label',
                    action: 'index'
            ]
    ]

    def selectionService
    def crmOrderService

    def domainClass = CrmPaymentTerm

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        def baseURI = new URI('gorm://crmPaymentTerm/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                grails.plugins.crm.core.WebUtils.setTenantData(request, 'crmPaymentTermQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        try {
            def result = selectionService.select(uri, params)
            [crmPaymentTermList: result, crmPaymentTermTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmPaymentTermList: [], crmPaymentTermTotal: 0, selection: uri]
        }
    }

    def create() {
        def crmPaymentTerm = crmOrderService.createPaymentTerm(params)
        switch (request.method) {
            case 'GET':
                return [crmPaymentTerm: crmPaymentTerm]
            case 'POST':
                if (!crmPaymentTerm.save(flush: true)) {
                    render view: 'create', model: [crmPaymentTerm: crmPaymentTerm]
                    return
                }

                flash.success = message(code: 'crmPaymentTerm.created.message', args: [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'), crmPaymentTerm.toString()])
                redirect action: 'list'
                break
        }
    }

    def edit() {
        switch (request.method) {
            case 'GET':
                def crmPaymentTerm = domainClass.get(params.id)
                if (!crmPaymentTerm) {
                    flash.error = message(code: 'crmPaymentTerm.not.found.message', args: [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'), params.id])
                    redirect action: 'list'
                    return
                }

                return [crmPaymentTerm: crmPaymentTerm]
            case 'POST':
                def crmPaymentTerm = domainClass.get(params.id)
                if (!crmPaymentTerm) {
                    flash.error = message(code: 'crmPaymentTerm.not.found.message', args: [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'), params.id])
                    redirect action: 'list'
                    return
                }

                if (params.version) {
                    def version = params.version.toLong()
                    if (crmPaymentTerm.version > version) {
                        crmPaymentTerm.errors.rejectValue('version', 'crmPaymentTerm.optimistic.locking.failure',
                                [message(code: 'crmPaymentTerm.label', default: 'Delivery Type')] as Object[],
                                "Another user has updated this Type while you were editing")
                        render view: 'edit', model: [crmPaymentTerm: crmPaymentTerm]
                        return
                    }
                }

                crmPaymentTerm.properties = params

                if (!crmPaymentTerm.save(flush: true)) {
                    render view: 'edit', model: [crmPaymentTerm: crmPaymentTerm]
                    return
                }

                flash.success = message(code: 'crmPaymentTerm.updated.message', args: [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'), crmPaymentTerm.toString()])
                redirect action: 'list'
                break
        }
    }

    def delete() {
        def crmPaymentTerm = domainClass.get(params.id)
        if (!crmPaymentTerm) {
            flash.error = message(code: 'crmPaymentTerm.not.found.message', args: [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'), params.id])
            redirect action: 'list'
            return
        }

        if (isInUse(crmPaymentTerm)) {
            render view: 'edit', model: [crmPaymentTerm: crmPaymentTerm]
            return
        }

        try {
            def tombstone = crmPaymentTerm.toString()
            crmPaymentTerm.delete(flush: true)
            flash.warning = message(code: 'crmPaymentTerm.deleted.message', args: [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'), tombstone])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmPaymentTerm.not.deleted.message', args: [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'), params.id])
            redirect action: 'edit', id: params.id
        }
    }

    private boolean isInUse(CrmPaymentTerm type) {
        def count = CrmOrder.countByPaymentTerm(type)
        def rval = false
        if (count) {
            flash.error = message(code: "crmPaymentTerm.delete.error.reference", args:
                    [message(code: 'crmPaymentTerm.label', default: 'Delivery Type'),
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
