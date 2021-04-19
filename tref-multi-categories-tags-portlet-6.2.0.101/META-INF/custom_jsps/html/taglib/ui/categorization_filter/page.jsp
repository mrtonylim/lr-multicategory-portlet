<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@page import="java.util.Collections"%>
<%@page import="com.liferay.portlet.asset.service.AssetCategoryLocalServiceUtil"%>
<%@page import="com.liferay.portal.kernel.util.ArrayUtil"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@page import="com.liferay.portlet.asset.service.AssetVocabularyLocalServiceUtil"%>
<%@page import="com.liferay.portlet.asset.model.AssetVocabulary"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Arrays"%>
<%@page import="com.liferay.portlet.asset.model.AssetCategory"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>
<%@page import="com.liferay.portal.kernel.util.StringUtil"%>

<%@ include file="/html/taglib/init.jsp" %>

<portlet:defineObjects />

<%
String assetType = GetterUtil.getString((String)request.getAttribute("liferay-ui:categorization-filter:assetType"), "content");
PortletURL portletURL = (PortletURL)request.getAttribute("liferay-ui:categorization-filter:portletURL");

if (Validator.isNull(portletURL)) {
	portletURL = renderResponse.createRenderURL();
}

/* INIZIO HOOK */
Map<Long, List<AssetCategory>> vocabularyCategories = new HashMap<Long, List<AssetCategory>>();

String categoryId = ParamUtil.getString(request, "categoryId");

long[] assetCategoryIds = new long[0];

String[] categoryIdsString = new String[0];

if (Validator.isNotNull(categoryId)) {
  categoryIdsString = StringUtil.split(categoryId);
}

if(categoryIdsString.length == 1) {
  
  long assetCategoryId = Long.parseLong(categoryIdsString[0]);
  
  if (assetCategoryId != 0L) {
	
    AssetCategory assetCategory = AssetCategoryLocalServiceUtil.getAssetCategory(assetCategoryId);
    
    vocabularyCategories.put(assetCategory.getVocabularyId(), Arrays.asList(assetCategory));
    
    assetCategoryIds = new long[]{assetCategoryId};
  }
} else if (categoryIdsString.length > 1) {
  
  	List<Long> assetCategoryIdsList = new ArrayList<Long>();

	for(String categoryIdString : categoryIdsString) {
	     
	  	long id = Long.parseLong(categoryIdString);
	  	
	  	if (id != 0L) {
	  
	  		AssetCategory assetCategory = AssetCategoryLocalServiceUtil.getAssetCategory(id);
	  	  
	  		if (!vocabularyCategories.containsKey(assetCategory.getVocabularyId())) {
	  			vocabularyCategories.put(assetCategory.getVocabularyId(), new ArrayList<AssetCategory>());
	  		}
	  		((List)vocabularyCategories.get(assetCategory.getVocabularyId())).add(assetCategory);
	  		
	  		assetCategoryIdsList.add(id);
	  	}
	}
	
	assetCategoryIds = ArrayUtil.toLongArray(assetCategoryIdsList);
}

String assetTagName = ParamUtil.getString(request, "tag", StringPool.BLANK);

String[] assetTagNames = StringUtil.split(assetTagName);

/* FINE HOOK */
%>

<c:if test="<%= !vocabularyCategories.isEmpty() %>">

	<%
	
	/* INIZIO HOOK */
	
	StringBuilder assetCategoriesTitle = new StringBuilder();
	
	for (Long vocabularyId : vocabularyCategories.keySet()) {
	  AssetVocabulary assetVocabulary = AssetVocabularyLocalServiceUtil.getVocabulary(vocabularyId);
	  assetVocabulary = assetVocabulary.toEscapedModel();
	%>
	
	<liferay-util:buffer var="removeCategory">
	
	<%  
	  List<AssetCategory> assetCategories = vocabularyCategories.get(vocabularyId);
	  for (AssetCategory assetCategory : assetCategories) {
	    assetCategory = assetCategory.toEscapedModel();
	    
	    List<AssetCategory> ancestorCategories = assetCategory.getAncestors();

		Collections.reverse(ancestorCategories);
		
		StringBuilder assetCategoryTitle = new StringBuilder();
		
	    for (AssetCategory ancestorCategory : ancestorCategories) {
	    	assetCategoryTitle.append(ancestorCategory.getTitle(locale) + " &raquo; ");
	    }
	    
		assetCategoryTitle.append(assetCategory.getTitle(locale));
		
		assetCategoriesTitle.append(assetCategoryTitle).append(StringPool.SPACE);
	%>
		<span class="asset-entry">
			<%= assetCategoryTitle.toString() %>

			<liferay-portlet:renderURL allowEmptyParam="<%= true %>" var="viewURLWithoutCategory">
				<liferay-portlet:param name="categoryId" value="<%=StringUtil.merge(ArrayUtil.remove(
				    assetCategoryIds, assetCategory.getCategoryId()))  %>" />
			</liferay-portlet:renderURL>

			<a href="<%= viewURLWithoutCategory %>" title="<liferay-ui:message key="remove" />">
				<span class="icon icon-remove textboxlistentry-remove"></span>
			</a>
		</span>
	<%
	  }
	%>	
	</liferay-util:buffer>
	
	<h2 class="taglib-categorization-filter entry-title">
		<liferay-ui:message arguments="<%= new String[] {assetVocabulary.getTitle(locale), removeCategory} %>" key='<%= assetType.concat("-with-x-x") %>' />
	</h2>
	<%
	}
	
	PortalUtil.addPageKeywords(assetCategoriesTitle.toString().replaceAll(" &raquo; ", StringPool.SPACE),
			request);
	
	PortalUtil.addPortletBreadcrumbEntry(request, 
	    assetCategoriesTitle.toString().replaceAll(" &raquo; ", StringPool.SPACE), currentURL);
	
	/* FINE HOOK */
	%>
	
</c:if>

<c:if test="<%= Validator.isNotNull(assetTagName) %>">

	<%

	/* INIZIO HOOK */
	
	StringBuilder assetTagsTitle = new StringBuilder();
	%>

	<liferay-util:buffer var="removeTag">
		<%
		for (String tagName : assetTagNames) {
		  assetTagsTitle.append(tagName).append(StringPool.SPACE);
		%>
			<span class="asset-entry">
				<%= HtmlUtil.escape(tagName) %>
	
				<liferay-portlet:renderURL allowEmptyParam="<%= true %>" var="viewURLWithoutTag">
					<liferay-portlet:param name="tag" value="<%=StringUtil.merge(ArrayUtil.remove(
					    assetTagNames, tagName))  %>" />
				</liferay-portlet:renderURL>
	
				<a href="<%= viewURLWithoutTag %>" title="<liferay-ui:message key="remove" />">
					<span class="icon icon-remove textboxlistentry-remove"></span>
				</a>
			</span>
		<%
		}
		%>
	</liferay-util:buffer>
		
	<h2 class="taglib-categorization-filter entry-title">
		<liferay-ui:message arguments="<%= removeTag %>" key='<%= assetType.concat("-with-tag-x") %>' />
	</h2>
	
	<%
	
	PortalUtil.addPageKeywords(assetTagsTitle.toString(), request);
	
	PortalUtil.addPortletBreadcrumbEntry(request, assetTagsTitle.toString(), currentURL);
	
	/* FINE HOOK */
	%>
	
</c:if>