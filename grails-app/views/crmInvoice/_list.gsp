<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmInvoice.number.label" default="Number"/>
        <th><g:message code="crmInvoice.orderDate.label" default="Order Date"/>
        <th><g:message code="crmInvoice.orderStatus.label" default="Status"/>
        <th><g:message code="crmInvoice.deliveryDate.label" default="Delivery Date"/>
        <th><g:message code="crmInvoice.delivery.label" default="Delivery Address"/>
        <th><g:message code="crmInvoice.paymentAmount.label" default="Order Value"/>
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
                    <g:formatDate type="date" date="${crmInvoice.orderDate}"/>
                </g:link>
            </td>

            <td>
                <g:fieldValue bean="${crmInvoice}" field="orderStatus"/>
            </td>

            <td>
                <g:formatDate type="date" date="${crmInvoice.deliveryDate}"/>
            </td>

            <td>
                ${fieldValue(bean: crmInvoice, field: "delivery")}
            </td>
            <td style="font-weight:bold;text-align: right;">
                <g:formatNumber type="currency" currencyCode="SEK" number="${crmInvoice.totalAmountVAT}"
                                maxFractionDigits="0"/>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>