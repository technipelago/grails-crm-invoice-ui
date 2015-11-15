<g:if test="${address?.addressee}">
    <dd>
        <g:if test="${crmContact}">
            <g:link controller="crmContact" action="show" id="${crmContact.id}">
                <g:fieldValue bean="${address}" field="addressee"/>
            </g:link>
        </g:if>
        <g:else>
            <g:fieldValue bean="${address}" field="addressee"/>
        </g:else>
    </dd>
</g:if>
<g:if test="${address?.address1}">
    <dd><g:fieldValue bean="${address}" field="address1"/></dd>
</g:if>
<g:if test="${address?.address2}">
    <dd><g:fieldValue bean="${address}" field="address2"/></dd>
</g:if>
<g:if test="${address?.address3}">
    <dd><g:fieldValue bean="${address}" field="address3"/></dd>
</g:if>
<g:if test="${address?.postalCode || address?.city}">
    <dd>
        <g:fieldValue bean="${address}" field="postalCode"/>
        <g:fieldValue bean="${address}" field="city"/>
    </dd>
</g:if>