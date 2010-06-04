using System;
using System.Security.Principal;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using ASP;

public partial class Controls_DisplayPerson : System.Web.UI.UserControl
{
    private string _username;
    private string _height;

    public string Username
    {
        get { return _username; }

        set { _username = value; }
    }

    public string Height
    {
        get { return _height; }

        set { _height = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        IPrincipal User = ((controls_displayperson_ascx)sender).Context.User;
        
        if (!IsPostBack)
        {
            ProfileCommon userProfile = PopulateProfile(User);

            Literal literal;
            foreach (Control control in Panel1.Controls)
            {
                if (control is Literal)
                {
                    literal = (Literal)control;
                    string litID = literal.ID.ToString().Substring(3, literal.ID.ToString().Length - 3);

                    literal.Text = userProfile.GetPropertyValue(litID).ToString();
                    literal.Visible = literal.Text.Equals(String.Empty) ? false : true;
                    literal.Text += "<br />";

                    Label litLabel = (Label)Panel1.FindControl("lbl" + litID);
                    litLabel.Visible = literal.Visible;
                }
            }

            if (userProfile.picture != null)
            {
                imgProfile.AlternateText = litName.Text;
                imgProfile.ImageUrl = "~/pichandler.ashx?username=" + userProfile.UserName;
                imgProfile.Height = Int32.Parse(_height);
                phImg.Visible = true;
            }

            if (User.Identity.Name == userProfile.UserName || User.IsInRole("Admin"))
            {
                phEdit.Visible = true;
                HyperLink1.NavigateUrl = "~/members/profile.aspx?username=" + userProfile.UserName;
            }
        }
    }

    private ProfileCommon PopulateProfile(IPrincipal User)
    {
        ProfileCommon userProfile = (ProfileCommon)ProfileCommon.Create(Username);
        if (Membership.GetUser(userProfile.UserName) == null) userProfile = (ProfileCommon)ProfileCommon.Create(User.Identity.Name);

        String grade = Request.QueryString["username"] == "Raile" ? "" : ", " + (String)userProfile.GetPropertyValue("Grade") + "th Grade";

        litName.Text = (String)userProfile.GetPropertyValue("First") + " " +
            (String)userProfile.GetPropertyValue("Last") + grade;

        return userProfile;
    }
}