<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="propertyDefinition" type="org.jahia.services.content.nodetypes.ExtendedPropertyDefinition"--%>
<%--@elvariable id="type" type="org.jahia.services.content.nodetypes.ExtendedNodeType"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>

<jcr:nodeProperty node="${currentNode}" name="jcr:title" var="title"/>
<jcr:nodeProperty node="${currentNode}" name="text" var="text"/>
<jcr:nodeProperty node="${currentNode}" name="jcr:createdBy" var="createdBy"/>
	
<c:set var="currentUser" value="${user:lookupUser(createdBy.string)}"/>

<jcr:nodeProperty node="${currentNode}" name="jcr:created" var="created"/>
<template:addResources type="css" resources="blog.css"/>
<c:if test="${jcr:isNodeType(currentNode, 'jnt:blogPost')}">
    <c:set var="blogHome" value="${url.base}${currentResource.node.parent.path}.html"/>
</c:if>
<c:if test="${!jcr:isNodeType(currentNode, 'jnt:blogPost')}">
    <c:set var="blogHome" value="${url.current}"/>
</c:if>
<div class="post">
    <fmt:formatDate value="${created.time}" type="date" pattern="dd" var="userCreatedDay"/>
    <fmt:formatDate value="${created.time}" type="date" pattern="MMM" var="userCreatedMonth"/>
    <div class="post-date"><span>${userCreatedMonth}</span>${userCreatedDay}</div>
    <h2 class="post-title"><a href="<c:url value='${url.base}${currentNode.path}.html'/>"><c:out value="${title.string}"/></a></h2>

    <p class="post-info"><fmt:message key="blog.label.by"/>&nbsp;<c:set var="fields" value="${currentNode.propertiesAsString}"/>
        ${user:fullName(currentUser)}
        &nbsp;-&nbsp;<fmt:formatDate value="${created.time}" type="date" dateStyle="medium"/>
        <!-- <a href="#"><fmt:message key="blog.category"/></a>    -->
    </p>
    <ul class="post-tags">
        <jcr:nodeProperty node="${currentNode}" name="j:tagList" var="assignedTags"/>
        <c:forEach items="${assignedTags}" var="tag" varStatus="status">
            <li>${fn:escapeXml(tag.string)}</li>
        </c:forEach>
    </ul>
    <div class="post-resume">
        <p>
            <c:out value="${fn:substring(functions:removeHtmlTags(text.string),0,1200)}" />
        </p>
    </div>
    <p class="read-more"><a title="#" href="<c:url value='${url.base}${currentNode.path}.html'/>"><fmt:message key="jnt_blog.readPost"/></a></p>
    <jcr:sql var="numberOfPostsQuery"
             sql="select [jcr:uuid] from [jnt:post] as p  where isdescendantnode(p,['${currentNode.path}'])"/>
    <c:set var="numberOfPosts" value="${numberOfPostsQuery.rows.size}"/>
    <p class="post-info-links">
        <c:if test="${numberOfPosts == 0}">
            <a class="comment_count" href="<c:url value='${url.base}${currentNode.path}.html#comments'/>">0 <fmt:message key="blog.comments"/></a>
        </c:if>
        <c:if test="${numberOfPosts > 0}">
            <a class="comment_count" href="<c:url value='${url.base}${currentNode.path}.html#comments'/>">${numberOfPosts} <fmt:message key="blog.comments"/></a>
        </c:if>
    </p>
    <!--stop post-->
</div>
<template:addCacheDependency path="${currentNode.path}/comments"/>