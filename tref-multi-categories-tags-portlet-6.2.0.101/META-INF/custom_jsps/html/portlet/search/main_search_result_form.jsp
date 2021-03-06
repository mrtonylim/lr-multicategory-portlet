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

<%@page import="com.liferay.portal.kernel.search.facet.config.FacetConfiguration"%>
<%@page import="com.liferay.portal.kernel.search.facet.Facet"%>
<%@page import="com.liferay.portal.kernel.search.SearchContext"%>
<%@page import="java.util.Comparator"%>
<%@page import="java.util.Collections"%>
<%@page import="com.liferay.portlet.asset.model.AssetVocabulary"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@page import="com.liferay.portal.kernel.util.ArrayUtil"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@page import="com.liferay.portal.kernel.util.StringUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.ArrayList"%>

<%@ include file="/html/portlet/search/init.jsp" %>

<%
ResultRow row = (ResultRow)request.getAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW);

Document document = (Document)row.getObject();

String className = document.get(Field.ENTRY_CLASS_NAME);

String entryTitle = null;
String entrySummary = null;
String downloadURL = null;
String returnToFullPageURL = (String)request.getAttribute("search.jsp-returnToFullPageURL");
PortletURL viewFullContentURL = null;
String viewURL = null;

AssetRendererFactory assetRendererFactory = AssetRendererFactoryRegistryUtil.getAssetRendererFactoryByClassName(className);

AssetRenderer assetRenderer = null;

boolean inheritRedirect = false;

if (assetRendererFactory != null) {
	long classPK = GetterUtil.getLong(document.get(Field.ENTRY_CLASS_PK));

	long resourcePrimKey = GetterUtil.getLong(document.get(Field.ROOT_ENTRY_CLASS_PK));

	if (resourcePrimKey > 0) {
		classPK = resourcePrimKey;
	}

	AssetEntry assetEntry = AssetEntryLocalServiceUtil.getEntry(className, classPK);

	assetRenderer = assetRendererFactory.getAssetRenderer(classPK);

	downloadURL = assetRenderer.getURLDownload(themeDisplay);

	viewFullContentURL = _getViewFullContentURL(request, themeDisplay, PortletKeys.ASSET_PUBLISHER, document);

	viewFullContentURL.setParameter("struts_action", "/asset_publisher/view_content");

	if (Validator.isNotNull(returnToFullPageURL)) {
		viewFullContentURL.setParameter("returnToFullPageURL", returnToFullPageURL);
	}

	viewFullContentURL.setParameter("assetEntryId", String.valueOf(assetEntry.getEntryId()));
	viewFullContentURL.setParameter("type", assetRendererFactory.getType());

	if (Validator.isNotNull(assetRenderer.getUrlTitle())) {
		if ((assetRenderer.getGroupId() > 0) && (assetRenderer.getGroupId() != scopeGroupId)) {
			viewFullContentURL.setParameter("groupId", String.valueOf(assetRenderer.getGroupId()));
		}

		viewFullContentURL.setParameter("urlTitle", assetRenderer.getUrlTitle());
	}

	if (viewInContext || !assetEntry.isVisible()) {
		inheritRedirect = true;

		String viewFullContentURLString = viewFullContentURL.toString();

		viewFullContentURLString = HttpUtil.setParameter(viewFullContentURLString, "redirect", currentURL);

		viewURL = assetRenderer.getURLViewInContext(liferayPortletRequest, liferayPortletResponse, viewFullContentURLString);

		viewURL = AssetUtil.checkViewURL(assetEntry, viewInContext, viewURL, currentURL, themeDisplay);
	}
	else {
		viewURL = viewFullContentURL.toString();
	}
}
else {
	String portletId = document.get(Field.PORTLET_ID);

	viewFullContentURL = _getViewFullContentURL(request, themeDisplay, portletId, document);

	if (Validator.isNotNull(returnToFullPageURL)) {
		viewFullContentURL.setParameter("returnToFullPageURL", returnToFullPageURL);
	}

	viewURL = viewFullContentURL.toString();
}

Indexer indexer = IndexerRegistryUtil.getIndexer(className);

Summary summary = null;

if (indexer != null) {
	String snippet = document.get(Field.SNIPPET);

	summary = indexer.getSummary(document, locale, snippet, viewFullContentURL);

	entryTitle = summary.getTitle();
	entrySummary = summary.getContent();
}
else if (assetRenderer != null) {
	entryTitle = assetRenderer.getTitle(locale);
	entrySummary = assetRenderer.getSearchSummary(locale);
}

if ((assetRendererFactory == null) && viewInContext) {
	viewURL = viewFullContentURL.toString();
}

viewURL = _checkViewURL(themeDisplay, viewURL, currentURL, inheritRedirect);

String[] queryTerms = (String[])request.getAttribute("search.jsp-queryTerms");

PortletURL portletURL = (PortletURL)request.getAttribute("search.jsp-portletURL");
%>

<span class="asset-entry">
	<span class="asset-entry-type">
		<%= ResourceActionsUtil.getModelResource(themeDisplay.getLocale(), className) %>

		<c:if test="<%= locale != summary.getLocale() %>">

			<%
			Locale summaryLocale = summary.getLocale();
			%>

			<liferay-ui:icon image='<%= "../language/" + LocaleUtil.toLanguageId(summary.getLocale()) %>' message='<%= LanguageUtil.format(locale, "this-result-comes-from-the-x-version-of-this-content", summaryLocale.getDisplayLanguage(locale), false) %>' />
		</c:if>
	</span>

	<span class="asset-entry-title">
		<a href="<%= viewURL %>">
			<c:if test="<%= assetRenderer != null %>">
				<img alt="" src="<%= assetRenderer.getIconPath(renderRequest) %>" />
			</c:if>

			<%= StringUtil.highlight(HtmlUtil.escape(entryTitle), queryTerms) %>
		</a>

		<c:if test="<%= Validator.isNotNull(downloadURL) %>">
			<liferay-ui:icon image="../arrows/01_down" label="<%= false %>" message='<%= LanguageUtil.format(pageContext, "download-x", HtmlUtil.escape(entryTitle)) %>' url="<%= downloadURL %>" />
		</c:if>
	</span>
	
	<%--INIZIO HOOK --%>
	<%
	
	SearchContext searchContext = (SearchContext) request.getAttribute("search.jsp-searchContext");
	
	boolean trefAssetCategoryFacet = false;
	boolean trefAssetTagFacet = false;
	
	Map<String, Facet> facets = searchContext.getFacets();

	for (Facet facet : facets.values()) {

		FacetConfiguration facetConfiguration =
			facet.getFacetConfiguration();
		
		String contextName = facetConfiguration.getData().getString("contextName");
		if (Validator.isNotNull(contextName) && contextName.equals("tref-multi-categories-tags-portlet")) {
		
			if (facetConfiguration.getDisplayStyle().equals("asset_multi_tags")) {
			  trefAssetTagFacet = true;
			}
			else if (facetConfiguration.getDisplayStyle().equals("asset_multi_categories")) {
			  trefAssetCategoryFacet = true;
			}
		}
	}
	
	String[] trefAssetCategoryIds = StringUtil.split(
	    ParamUtil.getString(request, Field.ASSET_CATEGORY_IDS, StringPool.BLANK));
	
	String[] trefAssetTagNames = StringUtil.split(
	    ParamUtil.getString(request, Field.ASSET_TAG_NAMES, StringPool.BLANK));
	%>
	<%--FINE HOOK --%>

	<%
	String[] assetCategoryIds = document.getValues(Field.ASSET_CATEGORY_IDS);
	String[] assetTagNames = document.getValues(Field.ASSET_TAG_NAMES);
	%>

	<c:if test="<%= Validator.isNotNull(entrySummary) || Validator.isNotNull(assetCategoryIds[0]) || Validator.isNotNull(assetTagNames[0]) %>">
		<div class="asset-entry-content">
			<c:if test="<%= Validator.isNotNull(entrySummary) %>">
				<span class="asset-entry-summary">
					<%= StringUtil.highlight(HtmlUtil.escape(entrySummary), queryTerms) %>
				</span>
			</c:if>

			<c:if test="<%= Validator.isNotNull(assetTagNames[0]) %>">
				<div class="asset-entry-tags">

					<%
					for (int i = 0; i < assetTagNames.length; i++) {
						String assetTagName = assetTagNames[i].trim();

						PortletURL tagURL = PortletURLUtil.clone(portletURL, renderResponse);

						/* INIZIO HOOK */
						
						if (trefAssetTagFacet) {
						  
						  String[] paramAssetTagNames = trefAssetTagNames;
						  if (!ArrayUtil.contains(paramAssetTagNames, assetTagName)) {
						    paramAssetTagNames = ArrayUtil.append(paramAssetTagNames, assetTagName);
						  }
							
						  tagURL.setParameter(Field.ASSET_TAG_NAMES, StringUtil.merge(paramAssetTagNames));
						}
						else {
						  tagURL.setParameter(Field.ASSET_TAG_NAMES, assetTagName);
						}
						
						tagURL.setParameter(Field.ASSET_CATEGORY_IDS, StringUtil.merge(trefAssetCategoryIds));

						/* FINE HOOK */
					%>

						<c:if test="<%= i == 0 %>">
							<div class="taglib-asset-tags-summary">
						</c:if>

						<a class="tag" href="<%= tagURL.toString() %>"><%= assetTagName %></a>

						<c:if test="<%= (i + 1) == assetTagNames.length %>">
							</div>
						</c:if>

					<%
					}
					%>

				</div>
			</c:if>

			<c:if test="<%= Validator.isNotNull(assetCategoryIds[0]) %>">
				<div class="asset-entry-categories">

					<%-- INIZIO HOOK --%>
					<%
					
					Map<Long, List<AssetCategory>> vocabularyCategories = new HashMap<Long, List<AssetCategory>>();
					
					for (int i = 0; i < assetCategoryIds.length; i++) {
						long assetCategoryId = GetterUtil.getLong(assetCategoryIds[i]);

						AssetCategory assetCategory = null;

						try {
							assetCategory = AssetCategoryLocalServiceUtil.getCategory(assetCategoryId);
						}
						catch (NoSuchCategoryException nsce) {
						}

						if ((assetCategory == null) || !permissionChecker.hasPermission(assetCategory.getGroupId(), assetCategory.getModelClassName(), assetCategory.getPrimaryKey(), ActionKeys.VIEW)) {
							
							continue;
						}
						
						if (!vocabularyCategories.containsKey(assetCategory.getVocabularyId())) {
						  vocabularyCategories.put(assetCategory.getVocabularyId(), new ArrayList<AssetCategory>());
						}
						((List<AssetCategory>)vocabularyCategories.get(assetCategory.getVocabularyId())).add(assetCategory);
					}
					
					List<AssetVocabulary> vocabularies = new ArrayList<AssetVocabulary>(vocabularyCategories.size());
					
					for (Long vocabularyId : vocabularyCategories.keySet()) {
						
					  	AssetVocabulary assetVocabulary = AssetVocabularyLocalServiceUtil.getVocabulary(vocabularyId);
		
					  	vocabularies.add(assetVocabulary);
					}
					
					// service.xml -> order by asc name
					Collections.sort(vocabularies, new Comparator<AssetVocabulary>() {

				      @Override
				      public int compare(AssetVocabulary assetVocabulary, AssetVocabulary assetVocabulary1) {
				        return assetVocabulary.getName().compareTo(assetVocabulary1.getName());
				      }

				    });
					
					%>
					
					<c:if test="<%=!vocabularies.isEmpty() %>"> 
						<div class="taglib-asset-categories-summary">
					</c:if>
					
					<%
					
					for (AssetVocabulary assetVocabulary: vocabularies) {
					  
					%>
					
						<span class="asset-vocabulary">
							<%= HtmlUtil.escape(assetVocabulary.getTitle(locale)) %>:
						</span>
						
					<%
						List<AssetCategory> categories = vocabularyCategories.get(assetVocabulary.getVocabularyId());
					
						for (AssetCategory assetCategory : categories) {
						
							PortletURL categoryURL = PortletURLUtil.clone(portletURL, renderResponse);
							
							if (trefAssetCategoryFacet) {
							  
							  String[] paramCategoryIds = trefAssetCategoryIds;
							  if (!ArrayUtil.contains(paramCategoryIds, String.valueOf(assetCategory.getCategoryId()))) {
							    paramCategoryIds = ArrayUtil.append(paramCategoryIds, String.valueOf(assetCategory.getCategoryId()));
							  }

							  categoryURL.setParameter(Field.ASSET_CATEGORY_IDS, StringUtil.merge(paramCategoryIds));
							}
							else {
							  categoryURL.setParameter(Field.ASSET_CATEGORY_IDS, String.valueOf(assetCategory.getCategoryId()));
							}
							
							categoryURL.setParameter(Field.ASSET_TAG_NAMES, StringUtil.merge(trefAssetTagNames));
					%>
	
							<a class="asset-category" href="<%= categoryURL.toString() %>">
								<%= _buildAssetCategoryPath(assetCategory, locale) %>
							</a>

					<%
						}
					}
					%>
					
					<c:if test="<%=!vocabularies.isEmpty() %>"> 
						</div>
					</c:if>
					<%-- FINE HOOK --%>
					
				</div>
			</c:if>
		</div>
	</c:if>
</span>