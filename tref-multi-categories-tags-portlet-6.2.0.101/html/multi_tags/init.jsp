
<%@page import="com.liferay.portal.kernel.util.PrefsParamUtil"%>

<%@include file="/html/init.jsp" %>

<%
long classNameId = PrefsParamUtil.getLong(portletPreferences, request, "classNameId");
String displayStyle = PrefsParamUtil.getString(portletPreferences, request, "displayStyle", "cloud");
long displayStyleGroupId = PrefsParamUtil.getLong(portletPreferences, request, "displayStyleGroupId", themeDisplay.getScopeGroupId());
int maxAssetTags = PrefsParamUtil.getInteger(portletPreferences, request, "maxAssetTags", 10);
boolean showAssetCount = PrefsParamUtil.getBoolean(portletPreferences, request, "showAssetCount");
boolean showZeroAssetCount = PrefsParamUtil.getBoolean(portletPreferences, request, "showZeroAssetCount");

boolean hidePortletWhenEmpty = true;
%>
