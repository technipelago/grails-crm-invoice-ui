<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmInvoice.label', default: 'Order')}"/>
    <title><g:message code="crmInvoice.list.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmInvoice.list.title" subtitle="crmInvoice.totalCount.label"
            args="[entityName, crmInvoiceTotal]"/>

<table class="table table-striped">
    <thead>
    <tr>
        <crm:sortableColumn property="number"
                            title="${message(code: 'crmInvoice.number.label', default: 'Number')}"/>
        <crm:sortableColumn property="orderDate"
                            title="${message(code: 'crmInvoice.orderDate.label', default: 'Date')}"/>
        <crm:sortableColumn property="orderStatus"
                            title="${message(code: 'crmInvoice.orderStatus.label', default: 'Status')}"/>
        <crm:sortableColumn property="customerLastName"
                            title="${message(code: 'crmInvoice.customer.label', default: 'Customer')}"/>
        <crm:sortableColumn property="deliveryType"
                            title="${message(code: 'crmInvoice.deliveryType.label', default: 'Delivery')}"/>
        <th><g:message code="crmInvoice.delivery.label"/></th>
        <crm:sortableColumn property="totalAmount" style="text-align: right;"
                            title="${message(code: 'crmInvoice.paymentAmount.label', default: 'Order Value')}"/>
    </tr>
    </thead>
    <tbody>
    <g:each in="${crmInvoiceList}" var="crmInvoice">
        <tr>

            <td>
                <select:link controller="crmInvoice" action="show" id="${crmInvoice.id}" selection="${selection}">
                    ${fieldValue(bean: crmInvoice, field: "number")}
                </select:link>
                <g:if test="${crmInvoice.syncPublished}">
                    <i class="icon-warning-sign"></i>
                </g:if>
            </td>

            <td>
                <select:link controller="crmInvoice" action="show" id="${crmInvoice.id}" selection="${selection}">
                    <g:formatDate type="date" date="${crmInvoice.orderDate}"/>
                </select:link>
            </td>

            <td>
                <g:fieldValue bean="${crmInvoice}" field="orderStatus"/>
            </td>

            <td>
                ${fieldValue(bean: crmInvoice, field: "customerName")}
            </td>

            <td>
                ${fieldValue(bean: crmInvoice, field: "deliveryType")}
            </td>
            <td>
                ${fieldValue(bean: crmInvoice, field: "delivery")}
            </td>
            <td style="text-align: right;">
                <g:formatNumber type="currency" currencyCode="SEK" number="${crmInvoice.totalAmountVAT}"
                                maxFractionDigits="0"/>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<crm:paginate total="${crmInvoiceTotal}"/>

<div class="form-actions btn-toolbar">
    <g:form>
        <input type="hidden" name="offset" value="${params.offset ?: ''}"/>
        <input type="hidden" name="max" value="${params.max ?: ''}"/>
        <input type="hidden" name="sort" value="${params.sort ?: ''}"/>
        <input type="hidden" name="order" value="${params.order ?: ''}"/>

        <g:each in="${selection.selectionMap}" var="entry">
            <input type="hidden" name="${entry.key}" value="${entry.value}"/>
        </g:each>

        <crm:selectionMenu visual="primary"/>

        <g:if test="${crmInvoiceTotal}">
            <div class="btn-group">
                <select:link action="export" accesskey="p" selection="${selection}" class="btn btn-info">
                    <i class="icon-print icon-white"></i>
                    <g:message code="crmInvoice.button.export.label" default="Print/Export"/>
                </select:link>
            </div>
        </g:if>

        <div class="btn-group">
            <crm:button type="link" action="create" visual="success" icon="icon-file icon-white"
                        label="crmInvoice.button.create.label" permission="crmInvoice:create"/>
        </div>
    </g:form>
</div>

</body>
</html>
