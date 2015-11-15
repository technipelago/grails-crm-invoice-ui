<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmPaymentTerm.label', default: 'Delivery Type')}"/>
    <title><g:message code="crmPaymentTerm.edit.title" args="[entityName, crmPaymentTerm]"/></title>
</head>

<body>

<crm:header title="crmPaymentTerm.edit.title" args="[entityName, crmPaymentTerm]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmPaymentTerm}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmPaymentTerm}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit"
                id="${crmPaymentTerm?.id}">
            <g:hiddenField name="version" value="${crmPaymentTerm?.version}"/>

            <f:with bean="crmPaymentTerm">
                <f:field property="name" input-autofocus=""/>
                <f:field property="description"/>
                <f:field property="param"/>
                <f:field property="icon"/>
                <f:field property="orderIndex"/>
                <f:field property="enabled"/>
            </f:with>

            <div class="form-actions">
                <crm:button visual="primary" icon="icon-ok icon-white" label="crmPaymentTerm.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmPaymentTerm.button.delete.label"
                            confirm="crmPaymentTerm.button.delete.confirm.message"
                            permission="crmPaymentTerm:delete"/>
                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmPaymentTerm.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>

</body>
</html>
