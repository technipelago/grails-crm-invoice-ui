<%@ page defaultCodec="html" %>
<tr>
    <td>
        <input type="hidden" name="items[${row}].id" value="${bean.id}"/>

        <input type="hidden" name="items[${row}].orderIndex" value="${bean.orderIndex ?: 0}"/>

        <g:select name="items[${row}].productId" from="${metadata.allProducts}"
                  value="${bean.productId}" optionKey="id" optionValue="id" style="width:99%;"/>
    </td>
    <td><input type="text" name="items[${row}].productName" value="${bean.productName}" style="width:99%;"/></td>
    <td><input type="text" name="items[${row}].comment" value="${bean.comment}" style="width:99%;"/></td>
    <td><input type="text" name="items[${row}].quantity" value="${formatNumber(number:bean.quantity)}" style="width:99%;" required=""/></td>
    <td><g:textField name="items[${row}].unit" value="${bean.unit}" style="width:99%;" required=""/></td>
    <td><input type="text" name="items[${row}].price" value="${formatNumber(number:bean.price, minFractionDigits: 2)}" required="" style="width:99%;"/></td>
    <td><g:select name="items[${row}].vat" from="${metadata.vatList}" value="${formatNumber(number:bean.vat, minFractionDigits: 2)}"
                  optionKey="${{formatNumber(number:it.value, minFractionDigits: 2)}}" optionValue="label" style="width:99%;"/></td>
    <td>
        <button type="button" class="btn btn-danger btn-small btn-delete" tabindex="-1" onclick="deleteItem(this, ${bean.id ?: 'undefined'})"><i class="icon-trash icon-white"></i></button>
    </td>

</tr>