using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class team : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString.AllKeys.Contains("name") && Enum.GetNames(typeof(Subteams.SubteamsEnum)).Contains(Request.QueryString["name"]))
        {
            dsTeams.SelectCommand = "SELECT * FROM [Teams] WHERE [TeamName] = '" + Request.QueryString["name"].Replace("'", "''") + "'";
            DataTable tblTeam = ((DataView)dsTeams.Select(DataSourceSelectArguments.Empty)).ToTable();
            if (tblTeam.Rows.Count == 1)
            {
                phReturn.Visible = true;
                pnlTeams.Visible = false;
                pnlTeam.Visible = true;

                litTeam.Text = ((DataRow)tblTeam.Rows[0])[1].ToString() + " ";
                ((Literal)pnlTeam.FindControl("litDescription")).Text = ((DataRow)tblTeam.Rows[0])[3].ToString();

                ((Repeater)pnlTeam.FindControl("TeamMembersRepeater1")).DataSource = Subteams.GetUsersInSubteam(Request.QueryString["name"]);
                ((Repeater)pnlTeam.FindControl("TeamMembersRepeater1")).DataBind();
            }
        }
        else
        {
            dsTeams.SelectCommand = "SELECT * FROM [Teams]";
        }
    }
    protected void TeamMembersRepeater1_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType != ListItemType.Separator) ((Controls_DisplayPerson)e.Item.FindControl("DisplayPerson1")).Username = e.Item.DataItem.ToString();
    }
}