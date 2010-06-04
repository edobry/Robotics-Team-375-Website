using System;
using System.IO;
using System.Text;
using System.Data;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;
using System.Reflection;
using System.Drawing;

public partial class profile : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ProfileCommon userProfile = CreateProfile();

            IEnumerable<TextBox> textBoxes = Panel1.Controls.OfType<TextBox>();
            foreach (TextBox txtbox in textBoxes)
            {
                txtbox.Text = userProfile.GetPropertyValue(txtbox.ID).ToString();
            }

            cblSubteams.DataSource = Subteams.SubteamsArray;
            cblSubteams.DataBind();
            foreach (string name in Subteams.ToArray(userProfile.GetPropertyValue("Subteam").ToString()))
            {
                cblSubteams.Items.FindByText(name).Selected = true;
            }

        }
    }

    public ProfileCommon CreateProfile()
    {
        ProfileCommon userProfile = null;
        if (User.IsInRole("Admin"))
        {
            userProfile = Request.QueryString["username"] != "" && Request.QueryString["username"] != null ? (ProfileCommon)ProfileCommon.Create(Request.QueryString["username"]) : (ProfileCommon)ProfileCommon.Create(User.Identity.Name);
        }
        else
        {
            userProfile = (Request.QueryString["username"] != "" && Request.QueryString["username"] != null) && User.Identity.Name == Request.QueryString["username"] ? (ProfileCommon)ProfileCommon.Create(Request.QueryString["username"]) : (ProfileCommon)ProfileCommon.Create(User.Identity.Name);
        }

        if (Membership.GetUser(userProfile.UserName) == null) userProfile = (ProfileCommon)ProfileCommon.Create(User.Identity.Name);
        return userProfile;
    }

    protected void updateProfile(object sender, EventArgs e)
    {
        if (User.Identity.Name == Request.QueryString["username"] || User.IsInRole("Admin"))
        {
            string editedUser = Request.QueryString.AllKeys.Contains("username") ? Request.QueryString["username"] : User.Identity.Name;
            ProfileCommon userProfile = (ProfileCommon)(Request.QueryString["username"] != "" ? ProfileCommon.Create(Request.QueryString["username"]) : HttpContext.Current.Profile);

            IEnumerable<TextBox> textBoxes = Panel1.Controls.OfType<TextBox>();
            foreach (TextBox txtbox in textBoxes) userProfile.SetPropertyValue(txtbox.ID, txtbox.Text);

            string[] selected = new string[]{};
            foreach (ListItem item in cblSubteams.Items)
            {
                if (item.Selected) { Array.Resize(ref selected, selected.Length + 1); Array.Copy(new object[] { item.Value }, 0, selected, selected.Length - 1, 1); }
            }
            userProfile.SetPropertyValue("Subteam", Subteams.FromArray(selected));

            if (FileUpload1.HasFile) userProfile.SetPropertyValue("Picture", (new Bitmap(FileUpload1.FileContent)));

            userProfile.Save();

            phConfirm.Visible = true;
            ((HyperLink)phConfirm.FindControl("hlProfile")).NavigateUrl += "?username=" + editedUser;
        }
    }
}