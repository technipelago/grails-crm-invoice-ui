<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmInvoice.label', default: 'Invoice')}"/>
    <title><g:message code="crmInvoice.show.title" args="[entityName, crmInvoice]"/></title>
    <r:script>
        $(document).ready(function () {
            $('#order-items tbody i').popover();
        });
    </r:script>
</head>

<body>

<g:set var="invoiceAddress" value="${crmInvoice.invoice}"/>
<g:set var="deliveryAddress" value="${crmInvoice.delivery}"/>

<div class="row-fluid">
<div class="span9">

<header class="page-header clearfix">
    <h1>
        <g:message code="crmInvoice.show.title" args="[entityName, crmInvoice]"/>
        <crm:user>
            <crm:favoriteIcon bean="${crmInvoice}"/>
        </crm:user>
        <g:if test="${crmInvoice.syncPending}">
            <i class="icon-share-alt"></i>
        </g:if>
        <g:if test="${crmInvoice.syncPublished}">
            <i class="icon-warning-sign"></i>
        </g:if>
        <small>${(crmInvoice.customerName ?: customer)?.encodeAsHTML()}</small>
    </h1>
</header>

<div class="tabbable">
<ul class="nav nav-tabs">
    <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmInvoice.tab.main.label"/></a>
    </li>
    <li><a href="#items" data-toggle="tab"><g:message code="crmInvoice.tab.items.label"/><crm:countIndicator
            count="${crmInvoice.items.size()}"/></a>
    </li>
    <crm:pluginViews location="tabs" var="view">
        <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
    </crm:pluginViews>
</ul>

<div class="tab-content">
<div class="tab-pane active" id="main">
<div class="row-fluid">
    <div class="span3">
        <dl>
            <dt><g:message code="crmInvoice.number.label" default="Number"/></dt>
            <dd><g:fieldValue bean="${crmInvoice}" field="number"/></dd>

            <g:if test="${crmInvoice?.invoiceStatus}">
                <dt><g:message code="crmInvoice.invoiceStatus.label" default="Status"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="invoiceStatus"/></dd>
            </g:if>

            <dt><g:message code="crmInvoice.invoiceDate.label" default="Date"/></dt>
            <dd><g:formatDate type="date" date="${crmInvoice.invoiceDate}"/></dd>

            <g:if test="${crmInvoice.dueDate}">
                <dt><g:message code="crmInvoice.dueDate.label" default="Due"/></dt>
                <dd><g:formatDate type="date" date="${crmInvoice.dueDate}"/></dd>
            </g:if>
            <g:if test="${crmInvoice.paymentTerm}">
                <dt><g:message code="crmInvoice.paymentTerm.label" default="Payment terms"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="paymentTerm"/></dd>
            </g:if>


            <g:if test="${crmInvoice.ref}">
                <dt><g:message code="crmInvoice.reference.label" default="Reference"/></dt>
                <dd><crm:referenceLink reference="${crmInvoice.reference}"/></dd>
            </g:if>

            <g:if test="${crmInvoice.reference2}">
                <dt><g:message code="crmInvoice.reference2.label" default="Our Reference"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="reference2"/></dd>
            </g:if>
        </dl>
    </div>

    <div class="span3">
        <dl>

            <g:if test="${crmInvoice.customerName != invoiceAddress?.addressee}">
                <dt><g:message code="crmInvoice.customer.label" default="Customer"/></dt>
                <dd><g:fieldValue bean="${crmInvoice}" field="customerName"/></dd>
                <g:if test="${crmInvoice.customerCompany != invoiceAddress?.addressee}">
                    <dd><g:fieldValue bean="${crmInvoice}" field="customerCompany"/></dd>
                </g:if>
            </g:if>

            <dt><g:message code="crmInvoice.invoice.label"/></dt>
            <g:render template="address" model="${[crmContact: customer, address: invoiceAddress]}"/>

            <g:if test="${crmInvoice.customerEmail}">
                <dt><g:message code="crmInvoice.customerEmail.label" default="Email"/></dt>

                <dd>
                    <a href="mailto:${crmInvoice.customerEmail}"><g:decorate include="abbreviate" max="25">
                        <g:fieldValue bean="${crmInvoice}" field="customerEmail"/>
                    </g:decorate></a>
                </dd>
            </g:if>

            <g:if test="${crmInvoice.customerTel}">
                <dt><g:message code="crmInvoice.customerTel.label" default="Telephone"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="customerTel"/></dd>
            </g:if>

            <g:if test="${crmInvoice.reference1}">
                <dt><g:message code="crmInvoice.reference1.label" default="Your Reference"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="reference1"/></dd>
            </g:if>
        </dl>

    </div>

    <div class="span3">
        <dl>
            <dt><g:message code="crmInvoice.delivery.label"/></dt>
            <g:render template="address"
                      model="${[crmContact: customer, address: deliveryAddress ?: invoiceAddress]}"/>

            <g:if test="${crmInvoice.reference3}">
                <dt><g:message code="crmInvoice.reference3.label" default="Reference 3"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="reference3"/></dd>
            </g:if>

            <g:if test="${crmInvoice.reference4}">
                <dt><g:message code="crmInvoice.reference4.label" default="Reference 4"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="reference4"/></dd>
            </g:if>
        </dl>
    </div>

    <div class="span3">
        <dl>
            <dt><g:message code="crmInvoice.totalAmount.label" default="Amount ex. VAT"/></dt>

            <dd><g:formatNumber type="currency" currencyCode="${crmInvoice.currency}"
                                number="${crmInvoice.totalAmount}"/></dd>
            <dt><g:message code="crmInvoice.totalVat.label" default="VAT"/></dt>

            <dd><g:formatNumber type="currency" currencyCode="${crmInvoice.currency}"
                                number="${crmInvoice.totalVat}"/></dd>

            <dt><g:message code="crmInvoice.totalAmountVAT.label" default="Amount incl. VAT"/></dt>

            <dd><g:formatNumber type="currency" currencyCode="${crmInvoice.currency}"
                                number="${crmInvoice.totalAmountVAT}"/></dd>

            <g:set var="cent" value="${Math.round(crmInvoice.totalAmountVAT).intValue() - crmInvoice.totalAmountVAT}"/>
            <g:if test="${cent > 0.005 || cent < -0.005}">
                <dt><g:message code="crmInvoice.cent.label" default="Öresutjämning"/></dt>

                <dd><g:formatNumber type="currency" currencyCode="${crmInvoice.currency}" number="${cent}"/>
                </dd>
            </g:if>
            <dt><g:message code="crmInvoice.totalAmountVAT.label" default="Totals inc. VAT"/></dt>

            <dd><h3 style="margin-top: 0;"><g:formatNumber type="currency" currencyCode="${crmInvoice.currency}"
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

                <dd>${message(code: 'crmInvoice.paymentType.' + crmInvoice.paymentType, default: crmInvoice.paymentType)}</dd>
            </g:if>

            <g:if test="${crmInvoice.paymentId}">
                <dt><g:message code="crmInvoice.paymentId.label" default="Payment ID"/></dt>

                <dd><g:fieldValue bean="${crmInvoice}" field="paymentId"/></dd>
            </g:if>

            <g:if test="${crmInvoice.payedAmount}">
                <dt><g:message code="crmInvoice.payedAmount.label" default="Payed Amount"/></dt>

                <dd><g:formatNumber type="currency" currencyCode="${crmInvoice.currency}"
                                    number="${crmInvoice.payedAmount}"/></dd>
            </g:if>
        </dl>
    </div>

</div>

<div class="form-actions btn-toolbar">
    <g:form>
        <g:hiddenField name="id" value="${crmInvoice.id}"/>

        <div class="btn-group">
            <crm:selectionMenu location="crmInvoice" visual="primary">
                <crm:button type="link" controller="crmInvoice" action="index"
                            visual="primary" icon="icon-search icon-white"
                            label="crmInvoice.find.label"/>
            </crm:selectionMenu>
        </div>

        <crm:button type="link" action="edit" id="${crmInvoice?.id}"
                    group="true" visual="warning" icon="icon-pencil icon-white"
                    label="crmInvoice.button.edit.label" permission="crmInvoice:edit">
        </crm:button>

        <div class="btn-group">
            <select:link action="export" accesskey="p" params="${[ns:'crmInvoice']}" selection="${new URI('bean://crmInvoiceService/list?id=' + crmInvoice.id)}" class="btn btn-info">
                <i class="icon-print icon-white"></i>
                <g:message code="crmInvoice.button.export.label" default="Print/Export"/>
            </select:link>
        </div>

        <div class="btn-group">
            <button class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                <i class="icon-info-sign icon-white"></i>
                <g:message code="crmInvoice.button.view.label" default="View"/>
                <span class="caret"></span></button>
            <ul class="dropdown-menu">
                <g:if test="${selection}">
                    <li>
                        <select:link action="list" selection="${selection}" params="${[view: 'list']}">
                            <g:message code="crmInvoice.show.result.label" default="Show result in list view"/>
                        </select:link>
                    </li>
                </g:if>
                <crm:hasPermission permission="crmInvoice:createFavorite">
                    <crm:user>
                        <g:if test="${crmInvoice.isUserTagged('favorite', username)}">
                            <li>
                                <g:link action="deleteFavorite" id="${crmInvoice.id}"
                                        title="${message(code: 'crmInvoice.button.favorite.delete.help', args: [crmInvoice])}">
                                    <g:message code="crmContact.button.favorite.delete.label"/></g:link>
                            </li>
                        </g:if>
                        <g:else>
                            <li>
                                <g:link action="createFavorite" id="${crmInvoice.id}"
                                        title="${message(code: 'crmInvoice.button.favorite.create.help', args: [crmInvoice])}">
                                    <g:message code="crmInvoice.button.favorite.create.label"/></g:link>
                            </li>
                        </g:else>
                    </crm:user>
                </crm:hasPermission>
            </ul>
        </div>

    </g:form>
</div>

<crm:timestamp bean="${crmInvoice}"/>

</div>

<div class="tab-pane" id="items">
    <g:render template="items" model="${[bean:crmInvoice, list: crmInvoice.items]}"/>
</div>

<crm:pluginViews location="tabs" var="view">
    <div class="tab-pane tab-${view.id}" id="${view.id}">
        <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
    </div>
</crm:pluginViews>
</div>

</div>

</div>

<div class="span3">

    <g:render template="/tags" plugin="crm-tags" model="${[bean: crmInvoice]}"/>

</div>
</div>

</body>
</html>
