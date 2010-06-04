<%@ WebHandler Language="C#" Class="PicHandler" %>

using System;
using System.IO;
using System.Web;
using System.Drawing;
using System.Drawing.Imaging;

public class PicHandler : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "image/jpeg";
        context.Response.Cache.SetCacheability(HttpCacheability.Public);

        ProfileCommon prof = new ProfileCommon();
        ProfileCommon prof2 = prof.GetProfile(context.Request.QueryString["UserName"]);
        Bitmap myBitmap = prof2.picture;

        byte[] b = GetImageBytes(myBitmap);
        context.Response.OutputStream.Write(b, 0, b.Length);
    }
    
    private byte[] GetImageBytes(Image image)
    {
        ImageCodecInfo codec = null;
 
        foreach (ImageCodecInfo e in ImageCodecInfo.GetImageEncoders())
        {
            if (e.MimeType == "image/png")
            {
                codec = e;
                break;
            }
        }
 
        using (EncoderParameters ep = new EncoderParameters())
        {
            ep.Param[0] = new EncoderParameter(Encoder.Quality, 100L);
 
            using (MemoryStream ms = new MemoryStream())
            {
                image.Save(ms, codec, ep);
                return ms.ToArray();
            }
        }
   } 
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}