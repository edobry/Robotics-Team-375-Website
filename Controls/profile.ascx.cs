using System;
using System.Collections;
using System.Collections.Specialized;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Web.UI;

public partial class Controls_profile : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SettingsPropertyCollection profileProperties = ProfileCommon.Properties;

        string[] settings;
        ArrayList keys = new ArrayList();
        ArrayList alias = new ArrayList();
        ArrayList name = new ArrayList();
        foreach (SettingsProperty prop in profileProperties)
        {
            if (prop.Attributes["CustomProviderData"].ToString() != "None")
            {
                settings = prop.Attributes["CustomProviderData"].ToString().Split(';');
                name.Add(settings[1] + prop.Name);
                alias.Add(settings[1] + settings[0]);
            }
        }
        name.Sort();
        alias.Sort();

        ArrayList name1 = ArrayList.Repeat("", name.Count);
        foreach (String item in name) name1[name.IndexOf(item)] = item.Substring(1);

        ArrayList alias1 = ArrayList.Repeat("", alias.Count);
        foreach (String item in alias) alias1[alias.IndexOf(item)] = item.Substring(1);

        int n = 0;
        StringDictionary properties = new StringDictionary();
        foreach (string item in name1) { properties[item] = alias1[n].ToString(); n++; }

        rptProfile.DataSource = properties;
        rptProfile.DataBind();
    }

    protected void rptProfile_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            TextBox txtItem = (TextBox)e.Item.FindControl("textbox");

            Label lblItem = (Label)e.Item.FindControl("label");
            lblItem.AssociatedControlID = txtItem.ID;
            lblItem.Text = ((DictionaryEntry)e.Item.DataItem).Value.ToString();
        }
    }
}

public class ProfileTemplate : ITemplate
{
    public ProfileTemplate() { }

    public void InstantiateIn(Control container)
    {
        throw new NotImplementedException();
    }


}