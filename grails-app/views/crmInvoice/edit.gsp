<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmInvoice.label', default: 'Invoice')}"/>
    <title><g:message code="crmInvoice.edit.title" args="[entityName, crmInvoice]"/></title>
    <r:require modules="datepicker,autocomplete"/>
    <script type="text/javascript">
        function deleteItem(source, id) {
            if(id) {
                $.post("${createLink(action: 'deleteItem')}", {id: id}, function(data) {
                    deleteTableRow(source);
                });
            } else {
                deleteTableRow(source);
            }
        }
        jQuery(document).ready(function () {
            <crm:datepicker/>

            // Put autocomplete on customer first name.
            $("input[name='customerFirstName']").autocomplete("${createLink(action: 'autocompleteCustomer')}", {
                remoteDataType: 'json',
                extraParams: {a: 'firstName'},
                preventDefaultReturn: true,
                minChars: 1,
                selectFirst: true,
                filterResults: false,
                matchSubset: false,
                useCache: false,
                maxItemsToShow: 20,
                displayValue: function (value, data) {
                    return data[3] || '';
                },
                onItemSelect: function (item) {
                    var data = item.data;
                    $("header h1 small").text(data[2]);
                    $("input[name='customerLastName']").val(data[4]);
                    $("input[name='customerNumber']").val(data[1]);
                    $("input[name='customerRef']").val('crmContact@' + data[0]);
                    $("input[name='customerEmail']").val(data[5]);
                    $("input[name='customerTel']").val(data[6]);
                    $("input[name='invoice.address1']").val(data[7]);
                    $("input[name='invoice.addressee']").val(data[2]);
                    $("input[name='invoice.address2']").val(data[8]);
                    $("input[name='invoice.postalCode']").val(data[10]);
                    $("input[name='invoice.city']").val(data[11]);
                }
            });
            // Put autocomplete on customer last name.
            $("input[name='customerLastName']").autocomplete("${createLink(action: 'autocompleteCustomer')}", {
                remoteDataType: 'json',
                extraParams: {a: 'lastName'},
                preventDefaultReturn: true,
                minChars: 1,
                selectFirst: true,
                filterResults: false,
                matchSubset: false,
                useCache: false,
                maxItemsToShow: 20,
                displayValue: function (value, data) {
                    return data[4] || '';
                },
                onItemSelect: function (item) {
                    var data = item.data;
                    $("header h1 small").text(data[2]);
                    $("input[name='customerFirstName']").val(data[3]);
                    $("input[name='customerNumber']").val(data[1]);
                    $("input[name='customerRef']").val('crmContact@' + data[0]);
                    $("input[name='customerEmail']").val(data[5]);
                    $("input[name='customerTel']").val(data[6]);
                    $("input[name='invoice.addressee']").val(data[2]);
                    $("input[name='invoice.address1']").val(data[7]);
                    $("input[name='invoice.address2']").val(data[8]);
                    $("input[name='invoice.postalCode']").val(data[10]);
                    $("input[name='invoice.city']").val(data[11]);
                }
            });

            // Put autocomplete on delivery name.
            $("input[name='delivery.addressee']").autocomplete("${createLink(action: 'autocompleteCustomer')}", {
                remoteDataType: 'json',
                preventDefaultReturn: true,
                minChars: 1,
                selectFirst: true,
                filterResults: false,
                matchSubset: false,
                useCache: false,
                maxItemsToShow: 20,
                displayValue: function (value, data) {
                    return data[2] || '';
                },
                onItemSelect: function (item) {
                    var data = item.data;
                    $("input[name='deliveryRef']").val('crmContact@' + data[0]);
                    if (data[9]) { /* TODO: THIS IS A HACK FOR ONE SWEDISH CUSTOMER! */
                        $("input[name='delivery.addressee']").val(data[9]);
                    } else {
                        $("input[name='delivery.addressee']").val(data[2]);
                    }
                    $("input[name='delivery.address1']").val(data[7]);
                    $("input[name='delivery.address2']").val(data[8]);
                    $("input[name='delivery.postalCode']").val(data[10]);
                    $("input[name='delivery.city']").val(data[11]);
                    $("input[name='reference3']").val(data[6]); // Phone
                    $("input[name='reference4']").val(data[5]); // Email
                }
            });

            $("#btn-add-item").click(function(ev) {
                $.get("${createLink(action: 'addItem', id: crmInvoice.id)}", function(markup) {
                    var table = $("#item-list");
                    var html = $(markup);
                    $("tbody", table).append(html);
                    table.renumberInputNames();
                    $(":input:enabled:first", html).focus();
                });
            });
        });
    </script>
</head>

<body>

<g:set var="invoiceAddress" value="${crmInvoice.invoice}"/>
<g:set var="deliveryAddress" value="${crmInvoice.delivery}"/>

<header class="page-header clearfix">
    <h1>
        <g:message code="crmInvoice.edit.title" args="[entityName, crmInvoice]"/>
        <g:if test="${crmInvoice.syncPending}">
            <i class="icon-share-alt"></i>
        </g:if>
        <g:if test="${crmInvoice.syncPublished}">
            <i class="icon-warning-sign"></i>
        </g:if>
        <small>${crmInvoice.customerName?.encodeAsHTML()}</small>
    </h1>
</header>

<g:hasErrors bean="${crmInvoice}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmInvoice}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:form action="edit">

<g:hiddenField name="id" value="${crmInvoice.id}"/>
<g:hiddenField name="version" value="${crmInvoice.version}"/>

<g:hiddenField name="invoice.addressee" value="${invoiceAddress?.addressee}"/>
<g:hiddenField name="customerNumber" value="${crmInvoice.customerNumber}"/>
<g:hiddenField name="customerRef" value="${crmInvoice.customerRef}"/>

<g:hiddenField name="delete.prices" value=""/>
<g:hiddenField name="delete.compositions" value=""/>

<div class="tabbable">
<ul class="nav nav-tabs">
    <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmInvoice.tab.main.label"/></a>
    </li>
    <li><a href="#items" data-toggle="tab"><g:message code="crmInvoice.tab.items.label"/><crm:countIndicator
            count="${crmInvoice.items.size()}"/></a></li>
    <crm:pluginViews location="tabs" var="view">
        <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
    </crm:pluginViews>
</ul>

<div class="tab-content">
<div class="tab-pane active" id="main">

<div class="row-fluid">

<div class="span3">
    <div class="row-fluid">
        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.number.label"/>
            </label>

            <div class="controls">
                <g:textField name="number" value="${crmInvoice.number}" class="span8" autofocus=""/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.invoiceDate.label"/>
            </label>

            <div class="controls">
                <div class="inline input-append date"
                     data-date="${formatDate(type: 'date', date: crmInvoice.invoiceDate ?: new Date())}">
                    <g:textField name="invoiceDate" class="span10" size="10"
                                 value="${formatDate(type: 'date', date: crmInvoice.invoiceDate)}"/><span
                        class="add-on"><i
                            class="icon-th"></i></span>
                </div>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.dueDate.label"/>
            </label>

            <div class="controls">
                <div class="inline input-append date"
                     data-date="${formatDate(type: 'date', date: crmInvoice.dueDate ?: new Date())}">
                    <g:textField name="dueDate" class="span10" size="10"
                                 value="${formatDate(type: 'date', date: crmInvoice.dueDate)}"/><span
                        class="add-on"><i
                            class="icon-th"></i></span>
                </div>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.invoiceStatus.label"/>
            </label>

            <div class="controls">
                <g:select name="invoiceStatus.id" from="${metadata.invoiceStatusList}"
                          value="${crmInvoice.invoiceStatusId}"
                          optionKey="id" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.reference1.label"/>
            </label>

            <div class="controls">
                <g:textField name="reference1" value="${crmInvoice.reference1}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.reference2.label"/>
            </label>

            <div class="controls">
                <g:textField name="reference2" value="${crmInvoice.reference2}" class="span12"/>
            </div>
        </div>
    </div>
</div>

<div class="span3">
    <div class="row-fluid">
        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.customerName.label"/>
            </label>

            <div class="controls">
                <g:textField name="customerFirstName" value="${crmInvoice.customerFirstName}" class="span5"
                             autocomplete="off"/>
                <g:textField name="customerLastName" value="${crmInvoice.customerLastName}" class="span7"
                             autocomplete="off"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.customerCompany.label"/>
            </label>

            <div class="controls">
                <g:textField name="customerCompany" value="${crmInvoice.customerCompany}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.invoice.address1.label"/>
            </label>

            <div class="controls">
                <g:textField name="invoice.address1" value="${invoiceAddress?.address1}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.invoice.address2.label"/>
            </label>

            <div class="controls">
                <g:textField name="invoice.address2" value="${invoiceAddress?.address2}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmAddress.postalAddress.label"/>
            </label>

            <div class="controls">
                <g:textField name="invoice.postalCode" value="${invoiceAddress?.postalCode}" class="span4"/>
                <g:textField name="invoice.city" value="${invoiceAddress?.city}" class="span8"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.customerTel.label"/>
            </label>

            <div class="controls">
                <g:textField name="customerTel" value="${crmInvoice.customerTel}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.customerEmail.label"/>
            </label>

            <div class="controls">
                <g:textField name="customerEmail" value="${crmInvoice.customerEmail}" class="span12"/>
            </div>
        </div>

    </div>
</div>

<div class="span3">
    <div class="row-fluid">

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.delivery.addressee.label"/>
            </label>

            <div class="controls">
                <g:textField name="delivery.addressee" value="${deliveryAddress?.addressee}"
                             class="span12" autocomplete="off"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.delivery.address1.label"/>
            </label>

            <div class="controls">
                <g:textField name="delivery.address1" value="${deliveryAddress?.address1}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.delivery.address2.label"/>
            </label>

            <div class="controls">
                <g:textField name="delivery.address2" value="${deliveryAddress?.address2}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmAddress.postalAddress.label"/>
            </label>

            <div class="controls">
                <g:textField name="delivery.postalCode" value="${deliveryAddress?.postalCode}" class="span4"/>
                <g:textField name="delivery.city" value="${deliveryAddress?.city}" class="span8"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.reference3.label"/>
            </label>

            <div class="controls">
                <g:textField name="reference3" value="${crmInvoice.reference3}" class="span12"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">
                <g:message code="crmInvoice.reference4.label"/>
            </label>

            <div class="controls">
                <g:textField name="reference4" value="${crmInvoice.reference4}" class="span12"/>
            </div>
        </div>
    </div>
</div>

<div class="span3">
    <div class="well" style="margin-top: 20px;">
        <dl>
            <dt><g:message code="crmInvoice.totalAmount.label" default="Total Amount"/></dt>

            <dd><g:formatNumber type="currency" currencyCode="SEK"
                                number="${crmInvoice.totalAmount}"/></dd>
            <dt><g:message code="crmInvoice.totalVat.label" default="VAT"/></dt>

            <dd><g:formatNumber type="currency" currencyCode="SEK"
                                number="${crmInvoice.totalVat}"/></dd>

            <g:set var="cent"
                   value="${Math.round(crmInvoice.totalAmountVAT).intValue() - crmInvoice.totalAmountVAT}"/>
            <g:if test="${cent > 0.001}">
                <dt><g:message code="crmInvoice.cent.label" default="Öresutjämning"/></dt>

                <dd><g:formatNumber type="currency" currencyCode="SEK" number="${cent}"
                                    maxFractionDigits="2"/>
                </dd>
            </g:if>
            <dt><g:message code="crmInvoice.totalAmountVAT.label" default="Totals inc. VAT"/></dt>

            <dd><h3 style="margin-top: 0;"><g:formatNumber type="currency" currencyCode="SEK"
                                                           number="${crmInvoice.totalAmountVAT}"
                                                           maxFractionDigits="0"/></h3>
            </dd>

            <dt><g:message code="crmInvoice.paymentStatus.label" default="Payment Status"/></dt>
            <dd>${message(code: 'crmInvoice.paymentStatus.' + crmInvoice.paymentStatus, default: crmInvoice.paymentStatus.toString())}</dd>

            <g:if test="${crmInvoice.paymentDate}">
                <dt><g:message code="crmInvoice.paymentDate.label" default="Payed Date"/></dt>
                <dd><g:formatDate type="date" date="${crmInvoice.paymentDate}"/></dd>
            </g:if>

            <g:if test="${crmInvoice.paymentType}">
                <dt><g:message code="crmInvoice.paymentType.label" default="Payment Type"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="paymentType"/></dd>
            </g:if>

            <g:if test="${crmInvoice.paymentId}">
                <dt><g:message code="crmInvoice.paymentId.label" default="Payment ID"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="paymentId"/></dd>
            </g:if>

            <g:if test="${crmInvoice.payedAmount}">
                <dt><g:message code="crmInvoice.payedAmount.label" default="Payed Amount"/></dt>

                <dd><g:formatNumber type="currency" currencyCode="SEK"
                                    number="${crmInvoice.payedAmount}"/></dd>
            </g:if>
        </dl>
    </div>
</div>

</div>

<div class="form-actions">
    <crm:button action="edit" visual="warning" icon="icon-ok icon-white" label="crmInvoice.button.save.label"/>
    <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                label="crmInvoice.button.delete.label"
                confirm="crmInvoice.button.delete.confirm.message" permission="crmInvoice:delete"/>
    <crm:button type="link" action="show" id="${crmInvoice.id}" icon="icon-remove"
                label="crmInvoice.button.cancel.label"
                accesskey="b"/>
</div>

</div>

<div class="tab-pane" id="items">
    <tmpl:itemsEdit bean="${crmInvoice}" metadata="${metadata}"/>
</div>

<crm:pluginViews location="tabs" var="view">
    <div class="tab-pane tab-${view.id}" id="${view.id}">
        <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
    </div>
</crm:pluginViews>

</div>
</div>

</g:form>

</body>
</html>
