<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmInvoice.label', default: 'Order')}"/>
    <title><g:message code="crmInvoice.find.title" args="[entityName]"/></title>
    <r:require modules="datepicker,autocomplete"/>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            <crm:datepicker/>

            $("input[name='status']").autocomplete("${createLink(action: 'autocompleteOrderStatus', params: [max: 20])}", {
                remoteDataType: 'json',
                useCache: false,
                filter: false,
                minChars: 1,
                preventDefaultReturn: true,
                selectFirst: true
            });

            $("input[name='type']").autocomplete("${createLink(action: 'autocompleteOrderType', params: [max: 20])}", {
                remoteDataType: 'json',
                useCache: false,
                filter: false,
                minChars: 1,
                preventDefaultReturn: true,
                selectFirst: true
            });

            $("input[name='delivery']").autocomplete("${createLink(action: 'autocompleteDeliveryType', params: [max: 20])}", {
                remoteDataType: 'json',
                useCache: false,
                filter: false,
                minChars: 1,
                preventDefaultReturn: true,
                selectFirst: true
            });

            $("input[name='tags']").autocomplete("${createLink(action: 'autocompleteTags', params: [max: 20])}", {
                remoteDataType: 'json',
                useCache: false,
                filter: false,
                minChars: 1,
                preventDefaultReturn: true,
                selectFirst: true
            });
        });
    </script>
</head>

<body>

<crm:header title="crmInvoice.find.title" args="[entityName]"/>

<g:form action="list">

    <div class="row-fluid">

        <f:with bean="cmd">
            <div class="span4">
                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.number.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="number" value="${cmd.number}" class="span8" autofocus=""/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.query.fromDate.label"/>
                    </label>

                    <div class="controls">
                        <div class="inline input-append date"
                             data-date="${cmd.fromDate ?: formatDate(type: 'date', date: new Date())}">
                            <g:textField name="fromDate" class="input-medium" size="10"
                                         value="${cmd.fromDate}"/><span
                                class="add-on"><i class="icon-th"></i></span>
                        </div>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.query.toDate.label"/>
                    </label>

                    <div class="controls">
                        <div class="inline input-append date"
                             data-date="${cmd.toDate ?: formatDate(type: 'date', date: new Date())}">
                            <g:textField name="toDate" class="input-medium" size="10"
                                         value="${cmd.toDate}"/><span
                                class="add-on"><i class="icon-th"></i></span>
                        </div>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.campaign.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="campaign" value="${cmd.campaign}" class="span8"/>
                    </div>
                </div>
            </div>

            <div class="span4">
                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.customer.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="customer" value="${cmd.customer}" class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.invoice.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="address" value="${cmd.address}" class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.customerEmail.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="email" value="${cmd.email}" class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.customerTel.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="telephone" value="${cmd.telephone}" class="span11"/>
                    </div>
                </div>
            </div>

            <div class="span4">
                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.orderType.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="type" value="${cmd.type}" class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.orderStatus.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="status" value="${cmd.status}" class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.deliveryType.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="delivery" value="${cmd.delivery}" class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmInvoice.tags.label"/>
                    </label>

                    <div class="controls">
                        <g:textField name="tags" value="${cmd.tags}" class="span11"/>
                    </div>
                </div>

            </div>

        </f:with>

    </div>

    <div class="form-actions btn-toolbar">
        <crm:selectionMenu visual="primary">
            <crm:button action="list" icon="icon-search icon-white" visual="primary"
                        label="crmInvoice.button.search.label"/>
        </crm:selectionMenu>
        <crm:button type="link" group="true" action="create" visual="success" icon="icon-file icon-white"
                    label="crmInvoice.button.create.label" permission="crmInvoice:create"/>
        <g:link action="clearQuery" class="btn btn-link"><g:message code="crmInvoice.button.query.clear.label"
                                                                    default="Reset fields"/></g:link>
    </div>

</g:form>

</body>
</html>
