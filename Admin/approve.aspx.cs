using System;
using System.Data;
using System.Text;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Runtime.Serialization.Formatters.Binary;

namespace TeamRaile
{
    public partial class Members_approve : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                
            }
        }

    protected void GridView1_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowIndex > -1 && !IsPostBack)
        {
            DataRowView drvRequest = (DataRowView)e.Row.DataItem;
            if (!drvRequest.Row.HasErrors)
            {
                ProfileRequest recProfile = new ProfileRequest(drvRequest);

                ((Literal)e.Row.FindControl("litFirst")).Text = recProfile.Request["first"];
                ((Literal)e.Row.FindControl("litLast")).Text = recProfile.Request["last"];
                ((Literal)e.Row.FindControl("litTelephone")).Text = recProfile.Request["telephone"];
                ((Literal)e.Row.FindControl("litEmail")).Text = recProfile.Request["email"];
                ((Literal)e.Row.FindControl("litCommittees")).Text = recProfile.Request["committees"];
                ((Literal)e.Row.FindControl("litCareer")).Text = recProfile.Request["career"];
                ((Literal)e.Row.FindControl("litSubject")).Text = recProfile.Request["subject"];
                ((Literal)e.Row.FindControl("litGrade")).Text = recProfile.Request["grade"];
                ((Literal)e.Row.FindControl("litHobbies")).Text = recProfile.Request["hobbies"];

                ((Button)e.Row.FindControl("btnApprove")).CommandArgument = recProfile.RequestID;
                ((Button)e.Row.FindControl("btnDeny")).CommandArgument = recProfile.RequestID;
            }
        }
    }

    protected void ApproveDeny(object sender, CommandEventArgs e)
    {
        GridViewRow gvrRequest = (GridViewRow)((DataControlFieldCell)(((Button)sender).Parent)).Parent;

        String[] saRequest = new String[3];
        saRequest[0] = e.CommandArgument.ToString();
        saRequest[1] = ((Label)gvrRequest.FindControl("RequesterLabel")).Text;
        saRequest[2] = ((Label)gvrRequest.FindControl("RequestLabel")).Text;

        ProfileRequest recProfile = new ProfileRequest(saRequest);

        switch (e.CommandName)
        {
            case "Approve":
                {
                    recProfile.Approve();
                    break;
                }
            case "Deny":
                {
                    recProfile.Deny();
                    break;
                }
        }

        Response.Redirect("~/admin/approve.aspx", true);

    }
}
}