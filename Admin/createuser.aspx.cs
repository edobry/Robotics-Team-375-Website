using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_createuser : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /*protected void CreateUserWizard1_CreatedUser(object sender, WizardNavigationEventArgs e)
    {
        Panel pControls = (Panel)EditProfileStep.FindControl("Panel1");
        ProfileCommon profile = (ProfileCommon)ProfileCommon.Create(CreateUserWizard1.UserName);
        
        foreach (Control control in pControls.Controls)
        {
            if (control is TextBox)
            {
                profile.SetPropertyValue(control.ID.ToString().Substring(3, control.ID.ToString().Length - 3), ((TextBox)control).Text);
            }
        }

        profile.SetPropertyValue("Email", CreateUserWizard1.Email);
        profile.SetPropertyValue("First", CreateUserWizard1.Password);
        profile.SetPropertyValue("Last", CreateUserWizard1..UserName);
        profile.SetPropertyValue("ID", Membership.GetUser(CreateUserWizard1.UserName));
        profile.Save();
    }*/

    protected void CreateUserWizard1_ContinueButtonClick1(object sender, EventArgs e)
    {
        ProfileCommon profile = (ProfileCommon)ProfileCommon.Create(CreateUserWizard1.UserName);
        profile.SetPropertyValue("Email", CreateUserWizard1.Email);
        profile.SetPropertyValue("Last", CreateUserWizard1.UserName);
        profile.Save();

        Response.Redirect("~/Members/profile.aspx?username=" + CreateUserWizard1.UserName);
    }
}