<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmInvoice.label', default: 'Order')}"/>
    <title><g:message code="crmInvoice.create.title" args="[entityName]"/></title>
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
          $('.crm-confirm').submit(function(ev) {
            if(confirm("${message(code: 'crmInvoice.batch.confirm', default: 'Press ok to create invoices')}")) {
              return true;
            }
            ev.preventDefault();
            return false;
          });
        });
    </script>
</head>

<body>

<g:set var="invoiceAddress" value="${crmInvoice.invoice}"/>
<g:set var="deliveryAddress" value="${crmInvoice.delivery}"/>

<crm:header title="crmInvoice.create.title" subtitle="${crmInvoice.reference}" args="[entityName]"/>

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

<g:form action="batch" class="crm-confirm">

    <input type="hidden" name="referer" value="${params.referer}"/>
    <input type="hidden" name="q" value="${select.encode(selection: selection)}"/>

    <div class="tabbable">
        <ul class="nav nav-tabs">
            <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmInvoice.tab.main.label"/></a>
            </li>
            <li><a href="#items" data-toggle="tab"><g:message code="crmInvoice.tab.items.label"/><crm:countIndicator
                    count="${crmInvoice.items?.size()}"/></a></li>
            <li><a href="#misc" data-toggle="tab"><g:message code="crmInvoice.tab.misc.label"/><crm:countIndicator
                        count="${crmInvoice.description ? 1 : 0}"/></a></li>
            <crm:pluginViews location="tabs" var="view">
                <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
            </crm:pluginViews>
        </ul>

        <div class="tab-content">
            <div class="tab-pane active" id="main">

                <div class="row-fluid">
                    <div class="span4">

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
                                          value="${crmInvoice.invoiceStatus?.id}"
                                          optionKey="id" class="span12"/>
                            </div>
                        </div>


                    </div>

                    <div class="span4">
                        <div class="control-group">
                            <label class="control-label">
                                <g:message code="crmInvoice.paymentTerm.label"/>
                            </label>

                            <div class="controls">
                                <g:select name="paymentTerm.id" from="${metadata.paymentTermList}"
                                          value="${crmInvoice.paymentTerm?.id}"
                                          optionKey="id" class="span12"/>
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


                <div class="form-actions">
                    <crm:button visual="success" icon="icon-ok icon-white" label="crmInvoice.button.batch.label"/>
                </div>

            </div>

            <div class="tab-pane" id="items">
                <tmpl:itemsEdit bean="${crmInvoice}" metadata="${metadata}" save="${false}"/>
            </div>

            <div class="tab-pane" id="misc">
                <div class="row-fluid">
                    <div class="span6">
                        <div class="control-group">
                            <%--
                            <label class="control-label">
                                <g:message code="crmInvoice.description.label" default="Description"/>
                            </label>
                            --%>
                            <div class="controls">
                                <g:textArea name="description" value="${crmInvoice.description}" rows="12" cols="70"
                                            class="span12"/>
                            </div>
                        </div>
                    </div>
                </div>
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
