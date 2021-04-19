package it.tref.liferay.multi.facet;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.search.BooleanClause;
import com.liferay.portal.kernel.search.BooleanClauseFactoryUtil;
import com.liferay.portal.kernel.search.BooleanClauseOccur;
import com.liferay.portal.kernel.search.BooleanQuery;
import com.liferay.portal.kernel.search.BooleanQueryFactoryUtil;
import com.liferay.portal.kernel.search.ParseException;
import com.liferay.portal.kernel.search.SearchContext;
import com.liferay.portal.kernel.search.TermQuery;
import com.liferay.portal.kernel.search.TermQueryFactoryUtil;
import com.liferay.portal.kernel.search.facet.MultiValueFacet;
import com.liferay.portal.kernel.search.facet.config.FacetConfiguration;
import com.liferay.portal.kernel.search.facet.util.FacetValueValidator;
import com.liferay.portal.kernel.util.ArrayUtil;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.StringUtil;

public class MultiValueAndFacet extends MultiValueFacet {

  public MultiValueAndFacet(SearchContext searchContext) {
    super(searchContext);
  }

  @Override
  protected BooleanClause doGetFacetClause() {
    SearchContext searchContext = getSearchContext();

    FacetConfiguration facetConfiguration = getFacetConfiguration();

    JSONObject dataJSONObject = facetConfiguration.getData();

    String[] values = null;

    if (isStatic() && dataJSONObject.has("values")) {
      JSONArray valuesJSONArray = dataJSONObject.getJSONArray("values");

      values = new String[valuesJSONArray.length()];

      for (int i = 0; i < valuesJSONArray.length(); i++) {
        values[i] = valuesJSONArray.getString(i);
      }
    }

    String[] valuesParam = StringUtil.split(GetterUtil.getString(searchContext.getAttribute(getFieldId())));

    if (!isStatic() && (valuesParam != null) && (valuesParam.length > 0)) {
      values = valuesParam;
    }

    if (ArrayUtil.isEmpty(values)) {
      return null;
    }

    BooleanQuery facetQuery = BooleanQueryFactoryUtil.create(searchContext);

    for (String value : values) {
      FacetValueValidator facetValueValidator = getFacetValueValidator();

      if ((searchContext.getUserId() > 0) && !facetValueValidator.check(searchContext, value)) {

        continue;
      }

      TermQuery termQuery = TermQueryFactoryUtil.create(searchContext, getFieldName(), value);

      try {
        facetQuery.add(termQuery, BooleanClauseOccur.MUST);
      } catch (ParseException pe) {
        _log.error(pe, pe);
      }
    }

    if (!facetQuery.hasClauses()) {
      return null;
    }

    return BooleanClauseFactoryUtil.create(searchContext, facetQuery, BooleanClauseOccur.MUST.getName());
  }

  private static Log _log = LogFactoryUtil.getLog(MultiValueAndFacet.class);

}
