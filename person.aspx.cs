using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.Administration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;

public partial class person : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString.AllKeys.Contains("username") || Page.User.Identity.IsAuthenticated)
                {
                    ProfileCommon userProfile = PopulateProfile();

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
                        phImg.Visible = true;
                    }

                    if (User.Identity.Name == userProfile.UserName || User.IsInRole("Admin"))
                    {
                        phEdit.Visible = true;
                        HyperLink1.NavigateUrl = "~/members/profile.aspx?username=" + userProfile.UserName;
                    }
                }
                else
                {
                    Response.Redirect("default.aspx", true);
                }
            }
        }

        private ProfileCommon PopulateProfile()
        {
            ProfileCommon userProfile = Request.QueryString["username"] != "" && Request.QueryString["username"] != null ? (ProfileCommon)ProfileCommon.Create(Request.QueryString["username"]) : (ProfileCommon)ProfileCommon.Create(User.Identity.Name);
            if (Membership.GetUser(userProfile.UserName) == null) userProfile = (ProfileCommon)ProfileCommon.Create(User.Identity.Name);

            String grade = Request.QueryString["username"] == "Raile" ? "" : ", " + (String)userProfile.GetPropertyValue("Grade") + "th Grade";

            litName.Text = (String)userProfile.GetPropertyValue("First") + " " +
                (String)userProfile.GetPropertyValue("Last") + grade;

            return userProfile;
        }
    }