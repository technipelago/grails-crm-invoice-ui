<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmInvoiceStatus.label', default: 'Order Status')}"/>
    <title><g:message code="crmInvoiceStatus.edit.title" args="[entityName, crmInvoiceStatus]"/></title>
</head>

<body>

<crm:header title="crmInvoiceStatus.edit.title" args="[entityName, crmInvoiceStatus]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmInvoiceStatus}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmInvoiceStatus}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit"
                id="${crmInvoiceStatus?.id}">
            <g:hiddenField name="version" value="${crmInvoiceStatus?.version}"/>

            <f:with bean="crmInvoiceStatus">
                <f:field property="name" input-autofocus=""/>
                <f:field property="description"/>
                <f:field property="param"/>
                <f:field property="icon"/>
                <f:field property="orderIndex"/>
                <f:field property="enabled"/>
            </f:with>

            <div class="form-actions">
                <crm:button visual="primary" icon="icon-ok icon-white" label="crmInvoiceStatus.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmInvoiceStatus.button.delete.label"
                            confirm="crmInvoiceStatus.button.delete.confirm.message"
                            permission="crmInvoiceStatus:delete"/>
                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmInvoiceStatus.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>

</body>
</html>
