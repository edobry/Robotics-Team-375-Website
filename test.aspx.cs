using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class test : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        List<String> usernames = new List<string>();
        if (Request.QueryString.AllKeys.Contains("username"))
        {
            usernames.Add(Request.QueryString["username"]);
            ProfileRepeater1.DataSource = usernames;
            ProfileRepeater1.DataBind();
        }
        else
        {
            ProfileRepeater1.DataSource = Roles.GetUsersInRole("Human");
            ProfileRepeater1.DataBind();
        }

        foreach (MembershipUser user in Membership.GetAllUsers())
        {
            if (((user.UserName != "TestUser") && (user.UserName != "TestAdmin")) && !(Roles.IsUserInRole(user.UserName,"Human")))
            {
                Roles.AddUserToRoles(user.UserName, new string[] { "Human", "User" });
            }
        }
        //DisplayPerson1.Username = Request.QueryString.AllKeys.Contains("username") || User.Identity.IsAuthenticated ? User.Identity.Name : Request.QueryString["username"];
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

    protected void ProfileRepeater1_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType != ListItemType.Separator) ((Controls_DisplayPerson)e.Item.FindControl("DisplayPerson1")).Username = e.Item.DataItem.ToString();
    }
}