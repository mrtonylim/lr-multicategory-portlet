package it.tref.liferay.multi.portlet;

import java.io.IOException;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;

import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.util.bridges.mvc.MVCPortlet;

/**
 * Portlet implementation class TagsCloudPortlet
 */
public class TagsNavigationPortlet extends MVCPortlet {

  @Override
  public void processAction(ActionRequest actionRequest, ActionResponse actionResponse) throws IOException,
      PortletException {

    String tags = ParamUtil.getString(actionRequest, "tags");

    if (Validator.isNotNull(tags)) {
      actionResponse.setRenderParameter("tag", tags);
    } else {
      actionResponse.setRenderParameter("tag", StringPool.BLANK);
    }

    actionResponse.setRenderParameter("resetCur", Boolean.TRUE.toString());

    super.processAction(actionRequest, actionResponse);
  }

}
