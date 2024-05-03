<table id="item-list" class="table">
    <thead>
    <tr>
        <th><g:message code="crmInvoiceItem.productId.label"/></th>
        <th><g:message code="crmInvoiceItem.productName.label"/></th>
        <th><g:message code="crmInvoiceItem.comment.label"/></th>
        <th><g:message code="crmInvoiceItem.quantity.label"/></th>
        <th><g:message code="crmInvoiceItem.unit.label"/></th>
        <th><g:message code="crmInvoiceItem.price.label"/></th>
        <th><g:message code="crmInvoiceItem.vat.label"/></th>
        <th></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${bean.items}" var="item" status="row">
        <g:render template="item" model="${[bean: item, row: row, metadata: metadata]}"/>
    </g:each>
    </tbody>
    <tfoot>
    <tr>
        <td colspan="7">
            <g:if test="${bean.id}">
                <crm:button action="edit" visual="warning" icon="icon-ok icon-white" label="crmInvoice.button.update.label"/>
            </g:if>
            <g:elseif test="${save}">
                <crm:button visual="warning" icon="icon-ok icon-white" label="crmInvoice.button.save.label"/>
            </g:elseif>
            <button type="button" class="btn btn-success" id="btn-add-item">
                <i class="icon-plus icon-white"></i>
                <g:message code="crmInvoiceItem.button.add.label" default="Add Item"/>
            </button>
        </td>
    </tr>
    </tfoot>
</table>
