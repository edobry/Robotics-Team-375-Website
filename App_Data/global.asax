using System;
using System.Web;
using System.Data;
using System.Linq;
using TeamRaile;


    /// <summary>
    /// Contains my site's global variables.
    /// </summary>
    public static class Global
    {
        /// <summary>
        /// Global variable storing important stuff.
        /// </summary>
        static System.Web.Profile.ProfileBase _oProfile = HttpContext.Current.Profile;
        static String _MasterPage = "~/layout.master";

        /// <summary>
        /// Get or set the static important data.
        /// </summary>
        public static System.Web.Profile.ProfileBase oProfile
        {
            get
            {
                return _oProfile;
            }
            set
            {
                _oProfile = value;
                _oProfile.Save();
            }
        }

        public static String MasterPage
        {
            get
            {
                return _MasterPage;
            }
            set
            {
                _MasterPage = value;
            }
        }
    }
}