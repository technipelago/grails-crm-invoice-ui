<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmInvoice.number.label" default="Number"/>
        <th><g:message code="crmInvoice.invoiceDate.label" default="Invoice Date"/>
        <th><g:message code="crmInvoice.dueDate.label" default="Due Date"/>
        <th><g:message code="crmInvoice.invoiceStatus.label" default="Status"/>
        <th><g:message code="crmInvoice.invoice.label" default="Address"/>
        <th><g:message code="crmInvoice.totalAmountVAT.label" default="Amount"/>
    </tr>
    </thead>
    <tbody>
    <g:each in="${result}" var="crmInvoice">
        <tr>

            <td>
                <g:link controller="crmInvoice" action="show" id="${crmInvoice.id}">
                    ${fieldValue(bean: crmInvoice, field: "number")}
                </g:link>
            </td>

            <td>
                <g:link controller="crmInvoice" action="show" id="${crmInvoice.id}">
                    <g:formatDate type="date" date="${crmInvoice.invoiceDate}"/>
                </g:link>
            </td>

            <td>
                <g:formatDate type="date" date="${crmInvoice.dueDate}"/>
            </td>

            <td>
                <g:fieldValue bean="${crmInvoice}" field="invoiceStatus"/>
            </td>

            <td>
                ${fieldValue(bean: crmInvoice, field: "invoice")}
            </td>
            <td style="font-weight:bold;text-align: right;">
                <g:formatNumber type="currency" currencyCode="${crmInvoice.currency}" number="${crmInvoice.totalAmountVAT}"
                                maxFractionDigits="0"/>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<div class="form-actions btn-toolbar">
    <div class="btn-group">
        <crm:button type="link" controller="crmInvoice" action="create" visual="success" icon="icon-file icon-white"
                    label="crmInvoice.button.create.label" permission="crmInvoice:create"
        params="${[ref: reference] + (createInvoice ?: [:])}"/>
    </div>
</div>
