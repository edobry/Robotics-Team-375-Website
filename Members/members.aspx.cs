using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Members_members : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        litName.Text = (String)HttpContext.Current.Profile["First"];
        linkProfile.NavigateUrl = "~/person.aspx?username=" + HttpContext.Current.Profile.UserName;
    }
}