
<%@page import="com.liferay.portal.kernel.util.GetterUtil"%>
<%@page import="com.liferay.portal.kernel.util.ArrayUtil"%>
<%@page import="com.liferay.portal.kernel.util.StringUtil"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>

<%@ include file="/html/portlet/search/facets/init.jsp" %>

<%
if (termCollectors.isEmpty()) {
	return;
}

String displayStyle = dataJSONObject.getString("displayStyle", "cloud");
int frequencyThreshold = dataJSONObject.getInt("frequencyThreshold");
int maxTerms = dataJSONObject.getInt("maxTerms", 10);
boolean showAssetCount = dataJSONObject.getBoolean("showAssetCount", true);

String[] assetTagNames = StringUtil.split(GetterUtil.getString(fieldParam, StringPool.BLANK));
%>

<div class="asset-tags <%= cssClass %>" data-facetFieldName="<%= facet.getFieldId() %>" data-facetMultiValue="<%=true%>" id="<%= randomNamespace %>facet">

	<aui:input name="<%= facet.getFieldId() %>" type="hidden" value="<%= fieldParam %>" />

	<ul class="<%= (showAssetCount && displayStyle.equals("cloud")) ? "tag-cloud" : "tag-list" %> nav nav-pills nav-stacked">
		<li class="facet-value default <%= Validator.isNull(fieldParam) ? "active" : StringPool.BLANK %>">
			<a data-value="" href="javascript:;"><aui:icon image="tag" /> <liferay-ui:message key="any" /> <liferay-ui:message key="<%= facetConfiguration.getLabel() %>" /></a>
		</li>

		<%
		int maxCount = 1;
		int minCount = 1;

		if (showAssetCount && displayStyle.equals("cloud")) {

			// The cloud style may not list tags in the order of frequency,
			// so keep looking through the results until we reach the maximum
			// number of terms or we run out of terms.

			for (int i = 0, j = 0; i < termCollectors.size(); i++, j++) {
				if (j >= maxTerms) {
					break;
				}

				TermCollector termCollector = termCollectors.get(i);

				int frequency = termCollector.getFrequency();

				if (frequencyThreshold > frequency) {
					j--;

					continue;
				}

				maxCount = Math.max(maxCount, frequency);
				minCount = Math.min(minCount, frequency);
			}
		}

		double multiplier = 1;

		if (maxCount != minCount) {
			multiplier = (double)5 / (maxCount - minCount);
		}

		for (int i = 0, j = 0; i < termCollectors.size(); i++, j++) {
			if (j >= maxTerms) {
				break;
			}

			TermCollector termCollector = termCollectors.get(i);
			
			boolean selezionato = ArrayUtil.contains(assetTagNames, termCollector.getTerm());  
		%>

			<c:if test="<%= selezionato %>">
				<aui:script use="liferay-token-list">
					Liferay.Search.tokenList.add(
						{
							fieldValues: '<%= renderResponse.getNamespace() + facet.getFieldId()
						    	+ StringPool.PIPE + StringUtil.merge(ArrayUtil.remove(assetTagNames,
						    	    termCollector.getTerm())) %>',
							text: '<%= HtmlUtil.escapeJS(termCollector.getTerm()) %>'
						}
					);
				</aui:script>
			</c:if>
				
		<%
			int popularity = (int)(1 + ((maxCount - (maxCount - (termCollector.getFrequency() - minCount))) * multiplier));

			if (frequencyThreshold > termCollector.getFrequency()) {
				j--;

				continue;
			}
		%>

			<li class="facet-value tag-popularity-<%= popularity %> <%= selezionato ? "active" : StringPool.BLANK %>">
				<%
				String dataValue = StringUtil.merge(ArrayUtil.append(assetTagNames,
				      String.valueOf(termCollector.getTerm())));
				%>
				<a data-value="<%= HtmlUtil.escapeAttribute(dataValue) %>" href="javascript:;">
					<%= HtmlUtil.escape(termCollector.getTerm()) %>

					<c:if test="<%= showAssetCount %>">
						<span class="badge badge-info frequency"><%= termCollector.getFrequency() %></span>
					</c:if>
				</a>
			</li>

		<%
		}
		%>

	</ul>
</div>
