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
<%@page import="com.liferay.portlet.asset.model.AssetVocabulary"%>
<%@page import="java.util.Comparator"%>
<%@page import="java.util.Collections"%>
<%@page import="com.liferay.portal.kernel.util.ArrayUtil"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>
<%@page import="com.liferay.portal.kernel.util.StringUtil"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>

<%@ include file="/html/portlet/search/init.jsp" %>

<%
ResultRow row = (ResultRow)request.getAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW);

Document document = (Document)row.getObject();

String entryClassName = document.get(Field.ENTRY_CLASS_NAME);

AssetRendererFactory assetRendererFactory = AssetRendererFactoryRegistryUtil.getAssetRendererFactoryByClassName(entryClassName);

AssetRenderer assetRenderer = null;

if (assetRendererFactory != null) {
	long classPK = GetterUtil.getLong(document.get(Field.ENTRY_CLASS_PK));

	long resourcePrimKey = GetterUtil.getLong(document.get(Field.ROOT_ENTRY_CLASS_PK));

	if (resourcePrimKey > 0) {
		classPK = resourcePrimKey;
	}

	assetRenderer = assetRendererFactory.getAssetRenderer(classPK);
}

String[] queryTerms = (String[])request.getAttribute("search.jsp-queryTerms");

PortletURL portletURL = (PortletURL)request.getAttribute("search.jsp-portletURL");
%>

<span class="asset-entry">
	<span class="asset-entry-type">
		<%= ResourceActionsUtil.getModelResource(locale, entryClassName) %>
	</span>

	<span class="toggle-details">[+]</span>

	<span class="asset-entry-title">
		<c:if test="<%= assetRenderer != null %>">
			<img alt="" src="<%= assetRenderer.getIconPath(renderRequest) %>" />
		</c:if>

		<%
		String name = document.get(locale, Field.NAME);

		if (Validator.isNull(name)) {
			name = document.get(locale, Field.TITLE);
		}

		if (Validator.isNull(name)) {
			name = document.get(locale, "fullName");
		}
		%>

		<%= HtmlUtil.escape(name) %>
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

	<c:if test="<%= Validator.isNotNull(assetCategoryIds[0]) || Validator.isNotNull(assetTagNames[0]) %>">
		<div class="asset-entry-content">
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

						if (assetCategory == null) {
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

	<table class="lfr-table asset-entry-fields hide">
		<thead>
			<tr>
				<th class="key">
					<liferay-ui:message key="key" />
				</th>
				<th class="value">
					<liferay-ui:message key="value" />
				</th>
			</tr>
		</thead>
		<tbody>

			<%
			List<Map.Entry<String, Field>> fields = new LinkedList(document.getFields().entrySet());

			Collections.sort(
				fields,
				new Comparator<Map.Entry<String, Field>>() {

					public int compare(Map.Entry<String, Field> entry1, Map.Entry<String, Field> entry2) {
						return entry1.getKey().compareTo(entry2.getKey());
					}

				}
			);

			for (Map.Entry<String, Field> entry : fields) {
				Field field = entry.getValue();

				String fieldName = field.getName();

				if (fieldName.equals(Field.UID)) {
					continue;
				}

				String[] values = field.getValues();
			%>

				<tr>
					<td class="key" valign="top">
						<strong><%= HtmlUtil.escape(field.getName()) %></strong>

						<br />

						<em>
							<liferay-ui:message key="array" /> = <%= values.length > 1 %>, <liferay-ui:message key="boost" /> = <%= field.getBoost() %>,<br />

							<liferay-ui:message key="numeric" /> = <%= field.isNumeric() %>, <liferay-ui:message key="tokenized" /> = <%= field.isTokenized() %>
						</em>
					</td>
					<td class="value" valign="top">
						<div class="container">
							<code>
								<c:if test="<%= values.length > 1 %>">[</c:if><%for (int i = 0; i < values.length; i++) {%><c:if test="<%= i > 0 %>">, </c:if><c:if test="<%= !field.isNumeric() %>">"</c:if><%= HtmlUtil.escape(values[i]) %><c:if test="<%= !field.isNumeric() %>">"</c:if><%}%><c:if test="<%= values.length > 1 %>">]</c:if>
							</code>
						</div>
					</td>
				</tr>

			<%
			}
			%>

		</tbody>
	</table>
</span>