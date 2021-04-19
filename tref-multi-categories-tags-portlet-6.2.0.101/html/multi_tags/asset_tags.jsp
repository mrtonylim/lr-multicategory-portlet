
<%@page import="com.liferay.portal.kernel.util.ArrayUtil"%>
<%@page import="javax.portlet.RenderResponse"%>
<%@page import="com.liferay.portal.kernel.util.StringUtil"%>
<%@page import="com.liferay.portal.kernel.util.WebKeys"%>
<%@page import="com.liferay.portlet.asset.util.comparator.AssetTagCountComparator"%>
<%@page import="com.liferay.portal.kernel.util.HtmlUtil"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>
<%@page import="com.liferay.portal.kernel.util.StringBundler"%>
<%@page import="com.liferay.portal.kernel.util.ListUtil"%>
<%@page import="com.liferay.portlet.asset.service.AssetTagServiceUtil"%>
<%@page import="com.liferay.portlet.asset.model.AssetTag"%>
<%@page import="java.util.List"%>
<%@page import="com.liferay.portal.util.PortalUtil"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@page import="com.liferay.portal.kernel.util.GetterUtil"%>

<%@ include file="/html/multi_tags/init.jsp" %>

<%

String tags = ParamUtil.getString(request, "tag", StringPool.BLANK);

String[] selectedTags = StringUtil.split(tags);

String tagsNavigation = _buildTagsNavigation(scopeGroupId, themeDisplay.getSiteGroupId(), selectedTags, renderResponse, classNameId, displayStyle, maxAssetTags, showAssetCount, showZeroAssetCount);

if (Validator.isNotNull(tagsNavigation)) {
%>

	<liferay-ui:panel-container cssClass="taglib-asset-tags-navigation" extended="<%= true %>" persistState="<%= true %>">
		<%= tagsNavigation %>
	</liferay-ui:panel-container>

<%
}
else {
	if (hidePortletWhenEmpty) {
		renderRequest.setAttribute(WebKeys.PORTLET_CONFIGURATOR_VISIBILITY, Boolean.TRUE);
	}
%>

	<div class="alert alert-info">
		<liferay-ui:message key="there-are-no-tags" />
	</div>

<%
}

if (Validator.isNotNull(tags)) {
	PortalUtil.addPortletBreadcrumbEntry(request, tags, currentURL);
}
%>

<%!
private String _buildTagsNavigation(long scopeGroupId, long siteGroupId, String[] selectedTagNames, RenderResponse renderResponse, long classNameId, String displayStyle, int maxAssetTags, boolean showAssetCount, boolean showZeroAssetCount) throws Exception {
	List<AssetTag> tags = null;

	if (showAssetCount && (classNameId > 0)) {
		tags = AssetTagServiceUtil.getTags(scopeGroupId, classNameId, null, 0, maxAssetTags, new AssetTagCountComparator());
	}
	else {
		tags = AssetTagServiceUtil.getGroupTags(siteGroupId, 0, maxAssetTags, new AssetTagCountComparator());
	}

	if (tags.isEmpty()) {
		return null;
	}

	tags = ListUtil.sort(tags);

	StringBundler sb = new StringBundler();

	sb.append("<ul class=\"tag-items ");

	if (showAssetCount && displayStyle.equals("cloud")) {
		sb.append("tag-cloud");
	}
	else {
		sb.append("tag-list");
	}

	sb.append("\">");

	int maxCount = 1;
	int minCount = 1;
	
	if (showAssetCount && displayStyle.equals("cloud")) {
		for (AssetTag tag : tags) {
			String tagName = tag.getName();

			int count = 0;

			if (classNameId > 0) {
				count = AssetTagServiceUtil.getTagsCount(scopeGroupId, classNameId, tagName);
			}
			else {
				count = AssetTagServiceUtil.getTagsCount(scopeGroupId, tagName);
			}

			if (!showZeroAssetCount && (count == 0)) {
				continue;
			}

			maxCount = Math.max(maxCount, count);
			minCount = Math.min(minCount, count);
		}
	}

	double multiplier = 1;

	if (maxCount != minCount) {
		multiplier = (double)5 / (maxCount - minCount);
	}

	for (AssetTag tag : tags) {
		String tagName = tag.getName();

		int count = 0;

		if (classNameId > 0) {
			count = AssetTagServiceUtil.getTagsCount(scopeGroupId, classNameId, tagName);
		}
		else {
			count = AssetTagServiceUtil.getTagsCount(scopeGroupId, tagName);
		}

		int popularity = (int)(1 + ((maxCount - (maxCount - (count - minCount))) * multiplier));

		if (!showZeroAssetCount && (count == 0)) {
			continue;
		}

		sb.append("<li class=\"tag-popularity-");
		sb.append(popularity);
		sb.append("\"><span>");
		
		PortletURL portletURL = renderResponse.createActionURL();
		
		String tagsParam = null;

		if (ArrayUtil.contains(selectedTagNames, tagName)) {
		 	tagsParam = StringUtil.merge(ArrayUtil.remove(selectedTagNames, tagName));
			sb.append("<a class=\"tag-selected\" href=\"");
		}
		else {
		  	tagsParam = StringUtil.merge(ArrayUtil.append(selectedTagNames, tagName));
			sb.append("<a href=\"");
		}
		
		portletURL.setParameter("tags", tagsParam);

		sb.append(HtmlUtil.escape(portletURL.toString()));
		sb.append("\">");
		sb.append(tagName);

		if (showAssetCount) {
			sb.append("<span class=\"tag-asset-count\">");
			sb.append(StringPool.SPACE);
			sb.append(StringPool.OPEN_PARENTHESIS);
			sb.append(count);
			sb.append(StringPool.CLOSE_PARENTHESIS);
			sb.append("</span>");
		}

		sb.append("</a></span></li>");
	}

	sb.append("</ul><br style=\"clear: both;\" />");

	return sb.toString();
}
%>