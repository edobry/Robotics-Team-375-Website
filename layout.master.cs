using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class layout : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Literal litFirstName = (Literal)LoginView1.FindControl("litFirstName");
        if (litFirstName != null)
        {
            ProfileCommon userProfile = (ProfileCommon)ProfileCommon.Create(Page.User.Identity.Name);
            litFirstName.Text = userProfile.first;
        }
    }

    protected void rptSubmenu_DataBinding(object sender, EventArgs e)
    {
        if (SiteMap.Provider.FindSiteMapNode(Request.Url.AbsolutePath) != null)
        {
            if (SiteMap.Provider.GetParentNode(SiteMap.Provider.FindSiteMapNode(Request.Url.AbsolutePath)).ResourceKey == "root")
            {
                srcSiteMap.StartFromCurrentNode = true;
                srcSiteMap.ShowStartingNode = false;
            }
            else
            {
                srcSiteMap.StartFromCurrentNode = false;
                srcSiteMap.StartingNodeUrl = SiteMap.Provider.GetParentNode(SiteMap.Provider.FindSiteMapNode(Request.FilePath)).Url;
            }
        }
    }
    protected void rptSubmenu_PreRender(object sender, EventArgs e)
    {
        rptSubmenu.Visible = rptSubmenu.Items.Count > 0 ? true : false;
    }

    protected void rptMenu_ItemCreated(object sender, RepeaterItemEventArgs e)
    {
        if ((e.Item.ItemType != ListItemType.Separator) && (!IsPostBack))
        {
            SiteMapNode nodeInfo = new SiteMapNode(srcSiteMap.Provider, SiteMap.CurrentNode.ResourceKey);
            nodeInfo.Url = ((SiteMapNode)e.Item.DataItem).Url;
            nodeInfo.Description = (Request.FilePath == ((SiteMapNode)e.Item.DataItem).Url) || (SiteMap.CurrentNode.ParentNode.Url == ((SiteMapNode)e.Item.DataItem).Url) ? "activeItem" : "";
            if(((SiteMapNode)e.Item.DataItem).ResourceKey == "Login") nodeInfo.Description = "hide";
            nodeInfo.Title = ((SiteMapNode)e.Item.DataItem).Title;
            e.Item.DataItem = nodeInfo;
        }
    }
    protected void rptSubmenu_ItemCreated(object sender, RepeaterItemEventArgs e)
    {
        if (SiteMap.Provider.FindSiteMapNode(Request.Url.AbsolutePath) != null && !IsPostBack)
        {
            if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem))
            {
                SiteMapNode nodeInfo = new SiteMapNode(srcSiteMap.Provider, SiteMap.CurrentNode.ResourceKey);
                nodeInfo.Url = ((SiteMapNode)e.Item.DataItem).Url;
                nodeInfo.Description = Request.FilePath == ((SiteMapNode)e.Item.DataItem).Url ? "activeItem" : "";
                nodeInfo.Title = ((SiteMapNode)e.Item.DataItem).Title;
                e.Item.DataItem = nodeInfo;
            }
        }
    }
}