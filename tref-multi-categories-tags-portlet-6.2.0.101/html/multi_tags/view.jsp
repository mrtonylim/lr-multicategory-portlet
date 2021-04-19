
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.liferay.portlet.portletdisplaytemplate.util.PortletDisplayTemplateUtil"%>
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
long portletDisplayDDMTemplateId = PortletDisplayTemplateUtil.getPortletDisplayTemplateDDMTemplateId(displayStyleGroupId, displayStyle);
%>

<c:choose>
	<c:when test="<%= portletDisplayDDMTemplateId > 0 %>">

		<%
		List<AssetTag> assetTags = null;

		if (showAssetCount && (classNameId > 0)) {
			assetTags = AssetTagServiceUtil.getTags(scopeGroupId, classNameId, null, 0, maxAssetTags, new AssetTagCountComparator());
		}
		else {
			assetTags = AssetTagServiceUtil.getGroupTags(themeDisplay.getSiteGroupId(), 0, maxAssetTags, new AssetTagCountComparator());
		}

		assetTags = ListUtil.sort(assetTags);

		Map<String, Object> contextObjects = new HashMap<String, Object>();

		contextObjects.put("scopeGroupId", new Long(scopeGroupId));
		%>

		<%= PortletDisplayTemplateUtil.renderDDMTemplate(pageContext, portletDisplayDDMTemplateId, assetTags, contextObjects) %>
	</c:when>
	<c:otherwise>
		
		<liferay-util:include page="/html/multi_tags/asset_tags.jsp" 
			servletContext="<%=getServletContext() %>" />
	
	</c:otherwise>
</c:choose>