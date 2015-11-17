<table id="invoice-items" class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmInvoiceItem.productId.label"/></th>
        <th><g:message code="crmInvoiceItem.productName.label"/></th>
        <th><g:message code="crmInvoiceItem.quantity.label"/></th>
        <th style="text-align:right;"><g:message code="crmInvoiceItem.price.label"/></th>
        <th style="text-align:right;"><g:message code="crmInvoiceItem.totalPrice.label"/></th>
        <th style="text-align:center;"><g:message code="crmInvoiceItem.vat.label"/></th>
        <th style="text-align:right;"><g:message code="crmInvoiceItem.totalPriceVAT.label"/></th>
    </tr>
    </thead>
    <tbody>
    <g:set var="totals" value="${0}"/>
    <g:set var="totalsVAT" value="${0}"/>
    <g:each in="${list}" var="item">
        <tr>
            <td><g:fieldValue bean="${item}" field="productId"/></td>
            <td>
                <g:fieldValue bean="${item}" field="productName"/>
                <g:if test="${item.comment}">
                    <i class="icon-comment" title="${message(code: 'crmInvoiceItem.comment.label', default: 'Comments')}:"
                       data-content="- ${item.comment}"></i>
                </g:if>
            </td>
            <td style="white-space: nowrap;"><g:formatNumber number="${item.quantity}"
                                                             maxFractionDigits="2"/> ${item.unit}</td>
            <td style="white-space: nowrap;text-align: right;"><g:formatNumber type="currency" currencyCode="${bean.currency}"
                                                                               number="${item.price}"/></td>
            <td style="white-space: nowrap;text-align: right;">
                <g:formatNumber type="currency" currencyCode="${bean.currency}" number="${item.totalPrice}"/>
            </td>
            <td style="white-space: nowrap;text-align: center;">
                <g:formatNumber type="percent" number="${item.vat}"/>
            </td>
            <td style="white-space: nowrap;text-align: right;"><strong>
                <g:formatNumber type="currency" currencyCode="${bean.currency}" number="${item.totalPriceVAT}"
                                minFractionDigits="2" maxFractionDigits="2"/></strong>
            </td>
        </tr>
        <g:set var="totals" value="${totals + item.totalPrice}"/>
        <g:set var="totalsVAT" value="${totalsVAT + item.totalPriceVAT}"/>
    </g:each>
    </tbody>
    <tfoot>
    <tr>
        <td colspan="4"></td>
        <td style="white-space: nowrap;text-align: right;">
            <g:formatNumber type="currency" currencyCode="${bean.currency}" number="${totals}" minFractionDigits="2"
                            maxFractionDigits="2"/></td>
        <td></td>
        <td style="white-space: nowrap;text-align: right;">
            <strong><g:formatNumber type="currency" currencyCode="${bean.currency}" number="${totalsVAT}" minFractionDigits="2"
                                    maxFractionDigits="2"/></strong>
        </td>
    </tr>
    </tfoot>
</table>