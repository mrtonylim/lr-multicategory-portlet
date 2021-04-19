
<%@page import="com.liferay.portlet.asset.model.AssetTag"%>
<%@page import="com.liferay.portal.util.PortalUtil"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.liferay.portal.kernel.template.TemplateHandlerRegistryUtil"%>
<%@page import="com.liferay.portal.kernel.template.TemplateHandler"%>
<%@page import="com.liferay.portlet.asset.AssetRendererFactoryRegistryUtil"%>
<%@page import="com.liferay.portal.security.permission.ResourceActionsUtil"%>
<%@page import="com.liferay.portlet.asset.model.AssetRendererFactory"%>
<%@page import="java.util.List"%>
<%@page import="com.liferay.portal.kernel.util.Constants"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>

<%@ include file="/html/multi_tags/init.jsp" %>

<liferay-portlet:actionURL portletConfiguration="true" var="configurationURL" />

<liferay-portlet:renderURL portletConfiguration="true" var="configurationRenderURL" />

<aui:form action="<%= configurationURL %>" method="post" name="fm">
	<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />
	<aui:input name="redirect" type="hidden" value="<%= configurationRenderURL %>" />

	<aui:fieldset>
		<ul class="lfr-tree unstyled">
			<li class="tree-item">
				<aui:input label="show-unused-tags" name="preferences--showZeroAssetCount--" type="checkbox" value="<%= showZeroAssetCount %>" />
			</li>

			<li class="tree-item">
				<aui:input name="preferences--showAssetCount--" type="checkbox" value="<%= showAssetCount %>" />

				<ul class="lfr-tree hide unstyled" id="<portlet:namespace />assetCountOptions">
					<li class="tree-item">
						<aui:select helpMessage="asset-type-asset-count-help" label="asset-type" name="preferences--classNameId--">
							<aui:option label="any" value="<%= classNameId == 0 %>" />

							<%
							List<AssetRendererFactory> assetRendererFactories = AssetRendererFactoryRegistryUtil.getAssetRendererFactories(company.getCompanyId());

							for (AssetRendererFactory assetRendererFactory : assetRendererFactories) {
							%>

								<aui:option label="<%= ResourceActionsUtil.getModelResource(locale, assetRendererFactory.getClassName()) %>" selected="<%= classNameId == assetRendererFactory.getClassNameId() %>" value="<%= assetRendererFactory.getClassNameId() %>" />

							<%
							}
							%>

						</aui:select>
					</li>
				</ul>
			</li>

			<li class="tree-item">
				<ul class="lfr-tree unstyled" id="<portlet:namespace />displayTemplateSettings">
					<div class="display-template">

						<%
						TemplateHandler templateHandler = TemplateHandlerRegistryUtil.getTemplateHandler(AssetTag.class.getName());

						List<String> displayStyles = new ArrayList<String>();

						displayStyles.add("number");
						displayStyles.add("cloud");
						%>

						<liferay-ui:ddm-template-selector
							classNameId="<%= PortalUtil.getClassNameId(templateHandler.getClassName()) %>"
							displayStyle="<%= displayStyle %>"
							displayStyleGroupId="<%= displayStyleGroupId %>"
							displayStyles="<%= displayStyles %>"
							refreshURL="<%= currentURL %>"
						/>
					</div>
				</ul>
			</li>

			<li class="tree-item">
				<aui:input label="max-num-of-tags" name="preferences--maxAssetTags--" type="text" value="<%= maxAssetTags %>" />
			</li>
		</ul>
	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" />
	</aui:button-row>
</aui:form>

<aui:script use="aui-base">
	var showAssetCount = A.one('#<portlet:namespace />showAssetCountCheckbox');

	function showHiddenFields() {
		var assetCountOptions = A.one('#<portlet:namespace />assetCountOptions');

		if (showAssetCount && assetCountOptions) {
			if (showAssetCount.get('checked')) {
				assetCountOptions.show();
			}
			else {
				assetCountOptions.hide();
			}
		}
	}

	showHiddenFields();

	showAssetCount.on('change', showHiddenFields);
</aui:script>