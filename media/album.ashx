<%@ class="Bleroy.Photo.Album" language="c#" %>
// Photo Album //<!--
//////////////////////////////////////////////////////////////////////////////////////////////
// Photo Album handler
// Originally created by Dmitry Robsman
// Modified by Bertrand Le Roy
// with the participation of David Ebbo
// http://www.gotdotnet.com/Workspaces/Workspace.aspx?id=1eceb66c-3bd0-4cdd-87d5-3fa0f4742032
//////////////////////////////////////////////////////////////////////////////////////////////
// Uses the Metadata public domain library by
// Drew Noakes (drew@drewnoakes.com)
// and adapted for .NET by Renaud Ferret (renaud91@free.fr)
// The library can be downloaded from
// http://renaud91.free.fr/MetaDataExtractor/
//////////////////////////////////////////////////////////////////////////////////////////////
// Version 2.1
//
// What's new:
// - Support for Windows XP title and comments
// - Added base class for ImageInfo and AlbumFolderInfo
// - Added NavigationMode property
//////////////////////////////////////////////////////////////////////////////////////////////
// Version 2.0
//
// What's new:
// - Default CSS embedded into the handler
// - Fixed the mirrored folder thumbnail
// - Now using strongly-typed HtmlTextWriter for default rendering
// - Handler can be used as a control (register as a user control)
// - Control can be fully templated for customized rendering
//
//////////////////////////////////////////////////////////////////////////////////////////////
// TODO:
// - All in one file and signed dll outputs using MS Build
// - Optional externalized config
//////////////////////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Web;
using System.Web.Caching;
using System.Web.Compilation;
using System.Web.UI;
using System.Web.UI.WebControls;

using com.drew.metadata.exif;
using com.drew.metadata.jpeg;
using com.drew.metadata.iptc;

using MetadataDirectory = com.drew.metadata.Directory;
using Metadata = com.drew.metadata.Metadata;
using Tag = com.drew.metadata.Tag;

namespace Bleroy.Photo {
    /// <summary>
    /// Static methods and constants for use by the Album class.
    /// </summary>
    internal static class ImageHelper {
        // the following constants constitute the handler's configuration:
        
        /// <summary>
        /// Size in pixels of the thumbnails.
        /// </summary>
        public const int ThumbnailSize = 120;
        
        /// <summary>
        /// Size in pixels of the preview images.
        /// </summary>
        public const int PreviewSize = 700;

        /// <summary>
        /// The background color of the image thumbnails and previews.
        /// </summary>
        private static readonly Color BackGround = Color.Black;
        
        /// <summary>
        /// The color used to draw borders around image thumbnails and previews.
        /// </summary>
        private static readonly Color BorderColor = Color.Beige;
        
        /// <summary>
        /// The width in pixels of the thumbnail border.
        /// </summary>
        private static readonly float ThumbnailBorderWidth = 2;
        
        /// <summary>
        /// The width in pixels of the image previews.
        /// </summary>
        private static readonly float PreviewBorderWidth = 3;
        
        /// <summary>
        /// The color of the shadow that's drawn around up folder stacked image thumbnails.
        /// </summary>
        private static readonly Color UpFolderBorderColor = Color.FromArgb(90, Color.Black);
        
        /// <summary>
        /// The width in pixels of the shadow that's drawn around up folder stacked image thumbnails.
        /// </summary>
        private static readonly float UpFolderBorderWidth = 2;
        
        /// <summary>
        /// The color of the arrow that's drawn on up folder thumbnails.
        /// </summary>
        private static readonly Color UpArrowColor = Color.FromArgb(200, Color.Beige);
        
        /// <summary>
        /// The color of the arrow that's drawn on up folder thumbnails.
        /// </summary>
        private static readonly float UpArrowWidth = 4;
        
        /// <summary>
        /// The relative size of the arrow that's drawn on up folder thumbnails.
        /// </summary>
        private static readonly float UpArrowSize = 0.125F;
        
        /// <summary>
        /// The number of images on the up folder thumbnail stack.
        /// </summary>
        private static readonly int UpFolderStackHeight = 3;

        /// <summary>
        /// The quality (between 0 and 100) of the thumbnail JPEGs.
        /// </summary>
        private static readonly long ThumbnailJpegQuality = 75L;

        /// <summary>
        /// Location of the cache.
        /// Can be Disk (recommended), Memory or None.
        /// </summary>
        private const CacheLocation Caching = CacheLocation.Disk;
        
        /// <summary>
        /// If using memory cache, the duration in minutes of the sliding expiration.
        /// </summary>
        private const int MemoryCacheSlidingDuration = 10;

        /// <summary>
        /// The default CSS that's requested by the header.
        /// </summary>
        private const string Css = @"
body, td
{
	font-family: Verdana, Arial, Helvetica;
	font-size: xx-small;
	color: Gray;
	background-color: White;
}

a 
{
	color: Black;
}

img 
{
	border: none;
}

.album 
{
}

.albumFloat 
{
    float: left;
    text-align: center;
    margin-right: 8px;
    margin-bottom: 4px;
}

.albumDetailsLink 
{
}

.albumMetaSectionHead 
{
	background-color: Gray;
	color: White;
	font-weight: bold;
}

.albumMetaName 
{
	font-weight: bold;
}

.albumMetaValue 
{
}
";

        private static string _imageCacheDir;
        private static string _appPath;

        /// <summary>
        /// Static constructor that sets up the caching directory
        /// </summary>
        static ImageHelper() {
            #pragma warning disable 162
            if (Caching == CacheLocation.Disk) {
                _imageCacheDir = Path.Combine(HttpRuntime.CodegenDir, "Album");
                Directory.CreateDirectory(_imageCacheDir);
                _appPath = HttpRuntime.AppDomainAppPath;
                if (_appPath[_appPath.Length - 1] == '\\') {
                    _appPath = _appPath.Substring(0, _appPath.Length - 1);
                }
            }
            #pragma warning restore 162
        }

        /// <summary>
        /// Gets the path for a cached image and its status.
        /// </summary>
        /// <param name="path">The path to the image.</param>
        /// <param name="imageTypeModifier">Type of image.</param>
        /// <param name="cachedPath">The physical path of the cached image (out parameter).</param>
        /// <returns>True if the cached image exists and is not outdated.</returns>
        public static bool GetCachedPathAndCheckCacheStatus(
            string path,
            string imageTypeModifier,
            out string cachedPath) {

            string cacheKey = imageTypeModifier + "_" + path.Substring(_appPath.Length);
            cacheKey = cacheKey.Replace('\\', '_').Replace(':', '_');
            cachedPath = Path.Combine(_imageCacheDir, cacheKey);

            return File.Exists(cachedPath) && File.GetLastWriteTime(cachedPath) > File.GetLastWriteTime(path);
        }

        /// <summary>
        /// Sends the default CSS to the response.
        /// </summary>
        /// <param name="response">The response where to write the CSS.</param>
        public static void GenerateCssResponse(HttpResponse response) {
            response.Write(Css);
        }

        /// <summary>
        /// Outputs a resized image to the HttpResponse object
        /// </summary>
        /// <param name="imageFile">The image file to serve.</param>
        /// <param name="size">The size in pixels of a bounding square around the reduced image.</param>
        /// <param name="thumbnail">True if the resized image is a thumbnail.</param>
        /// <param name="response">The HttpResponse to output to.</param>
        public static void GenerateResizedImageResponse(
            string imageFile,
            int size,
            bool thumbnail,
            HttpResponse response) {

            string buildPath = null;

            #pragma warning disable 162
            switch (Caching) {
                case CacheLocation.Disk:
                    if (GetCachedPathAndCheckCacheStatus(imageFile, (thumbnail ? "thumbnail" : "preview"), out buildPath)) {
                        WriteNewImage(buildPath, response);
                        return;
                    }
                    break;
                case CacheLocation.Memory:
                    if (thumbnail) {
                        buildPath = (thumbnail ? "thumbnail_" : "preview_") + imageFile.Replace('\\', '_').Replace(':', '_');
                        byte[] cachedBytes = (byte[])HttpRuntime.Cache.Get(buildPath);

                        if (cachedBytes != null) {
                            WriteNewImage(cachedBytes, response);
                            return;
                        }
                    }
                    break;
            }
            #pragma warning restore 162

            using (Bitmap originalImage = LoadOriginalImage(imageFile)) {
                using (Bitmap newImage = CreateNewImage(originalImage, size, thumbnail)) {

                    WriteNewImage(newImage, response);

                    #pragma warning disable 162
                    switch (Caching) {
                        case CacheLocation.Disk:
                            File.WriteAllBytes(buildPath, GetImageBytes(newImage));
                            break;
                        case CacheLocation.Memory:
                            if (thumbnail) {
                                HttpRuntime.Cache.Insert(buildPath, GetImageBytes(newImage),
                                    new CacheDependency(imageFile), DateTime.MaxValue, TimeSpan.FromMinutes(MemoryCacheSlidingDuration));
                            }
                            break;
                    }
                    #pragma warning restore 162
                }
            }
        }

        /// <summary>
        /// Outputs a folder thumbnail to the HttpResponse.
        /// </summary>
        /// <param name="isParentFolder">True if an up arrow must be drawn.</param>
        /// <param name="folder">Folder path.</param>
        /// <param name="size">The size in pixels of the thumbnail.</param>
        /// <param name="response">The HttpResponse to output to.</param>
        public static void GenerateFolderImageResponse(
            bool isParentFolder,
            string folder,
            int size,
            HttpResponse response) {

            string buildPath = null;

            #pragma warning disable 162
            switch (Caching) {
                case CacheLocation.Disk:
                    if (GetCachedPathAndCheckCacheStatus(folder, (isParentFolder ? "parent" : "folder"), out buildPath)) {
                        WriteNewImage(buildPath, response);
                        return;
                    }
                    break;
                case CacheLocation.Memory: {
                        buildPath = (isParentFolder ? "parent_" : "folder_") + folder.Replace('\\', '_').Replace(':', '_');
                        byte[] cachedBytes = (byte[])HttpRuntime.Cache.Get(buildPath);

                        if (cachedBytes != null) {
                            WriteNewImage(cachedBytes, response);
                            return;
                        }
                    }
                    break;
            }
            #pragma warning restore 162

            Bitmap folderImage = CreateFolderImage(isParentFolder, folder, size);

            #pragma warning disable 162
            switch (Caching) {
                case CacheLocation.Disk:
                    File.WriteAllBytes(buildPath, GetImageBytes(folderImage));
                    break;
                case CacheLocation.Memory:
                    HttpRuntime.Cache.Insert(buildPath, GetImageBytes(folderImage),
                        null, DateTime.MaxValue, TimeSpan.FromMinutes(MemoryCacheSlidingDuration));
                    break;
            }

            WriteNewImage(folderImage, response);
            folderImage.Dispose();
        }
        #pragma warning restore 162

        /// <summary>
        /// Prepares a string to be used in JScript by escaping characters.
        /// </summary>
        /// <remarks>This is not a general purpose escaping function:
        /// we do not encode characters that can't be in Windows paths.
        /// It should not be used in general to prevent injection attacks.</remarks>
        /// <param name="unencoded">The unencoded string.</param>
        /// <returns>The encoded string.</returns>
        public static string JScriptEncode(string unencoded) {
            System.Text.StringBuilder sb = null;
            int checkedIndex = 0;
            int len = unencoded.Length;
            for (int i = 0; i < len; i++) {
                char c = unencoded[i];
                if ((c == '\'') || (c == '\"')) {
                    if (sb == null) {
                        sb = new System.Text.StringBuilder(len + 1);
                    }
                    sb.Append(unencoded.Substring(checkedIndex, i - checkedIndex));
                    sb.Append('\\');
                    sb.Append(unencoded[i]);
                    checkedIndex = i + 1;
                }
            }
            if (sb == null) {
                return unencoded;
            }
            if (checkedIndex < len) {
                sb.Append(unencoded.Substring(checkedIndex));
            }
            return sb.ToString();
        }

        /// <summary>
        /// Creates a Bitmap object from a file.
        /// </summary>
        /// <param name="imageFile">The path ofthe image.</param>
        /// <returns>The bitmap object.</returns>
        static Bitmap LoadOriginalImage(string imageFile) {
            return (Bitmap)Bitmap.FromFile(imageFile, false);
        }

        /// <summary>
        /// Creates a reduced Bitmap from a full-size Bitmap.
        /// </summary>
        /// <param name="originalImage">The full-size bitmap to reduce.</param>
        /// <param name="size">The size in pixels of a square bounding the reduced bitmap.</param>
        /// <param name="thumbnail">True if the reduced image is a thumbnail.</param>
        /// <returns>The reduced Bitmap.</returns>
        static Bitmap CreateNewImage(Bitmap originalImage, int size, bool thumbnail) {
            int originalWidth = originalImage.Width;
            int originalHeight = originalImage.Height;
            int width, height;
            int drawXOffset, drawYOffset, drawWidth, drawHeight;

            if (size > 0 && originalWidth >= originalHeight && originalWidth > size) {
                width = size;
                height = Convert.ToInt32((double)size * (double)originalHeight / (double)originalWidth);
            }
            else if (size > 0 && originalHeight >= originalWidth && originalHeight > size) {
                width = Convert.ToInt32((double)size * (double)originalWidth / (double)originalHeight);
                height = size;
            }
            else {
                width = originalWidth;
                height = originalHeight;
            }

            drawXOffset = 0;
            drawYOffset = 0;
            drawWidth = width;
            drawHeight = height;

            if (thumbnail) {
                width = Math.Max(width, size);
                height = Math.Max(height, size);
                drawXOffset = (width - drawWidth) / 2;
                drawYOffset = (height - drawHeight) / 2;
            }

            Bitmap newImage = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(newImage);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.SmoothingMode = SmoothingMode.AntiAlias;

            float borderWidth = thumbnail ? ThumbnailBorderWidth : PreviewBorderWidth;
            g.FillRectangle(new SolidBrush(BackGround), 0, 0, width, height);
            Pen BorderPen = new Pen(BorderColor);
            BorderPen.Width = borderWidth;
            BorderPen.LineJoin = LineJoin.Round;
            BorderPen.StartCap = LineCap.Round;
            BorderPen.EndCap = LineCap.Round;
            g.DrawRectangle(BorderPen,
                drawXOffset + borderWidth / 2,
                drawYOffset + borderWidth / 2,
                drawWidth - borderWidth,
                drawHeight - borderWidth);

            g.DrawImage(originalImage,
                drawXOffset + borderWidth,
                drawYOffset + borderWidth,
                drawWidth - 2 * borderWidth,
                drawHeight - 2 * borderWidth);
            g.Dispose();
            return newImage;
        }

        /// <summary>
        /// Creates the thumbnail Bitmap for a folder.
        /// </summary>
        /// <param name="isParentFolder">True if the up arrow must be drawn.</param>
        /// <param name="folder">The path of the folder.</param>
        /// <param name="size">The size in pixels of a square bounding the thumbnail.</param>
        /// <returns>The thumbnail Bitmap.</returns>
        static Bitmap CreateFolderImage(bool isParentFolder, string folder, int size) {
            Bitmap newImage = new Bitmap(size, size);
            Graphics g = Graphics.FromImage(newImage);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.SmoothingMode = SmoothingMode.AntiAlias;

            Random rnd = new Random();
            List<string> imagesToDraw = new List<string>();
            int nbFound;
            string[] images = Directory.GetFiles(folder, "default.jpg", SearchOption.AllDirectories);
            for (nbFound = 0; nbFound < Math.Min(UpFolderStackHeight, images.Length); nbFound++) {
                imagesToDraw.Insert(0, images[nbFound]);
            }
            if (nbFound < UpFolderStackHeight) {
                images = Directory.GetFiles(folder, "*.jpg", SearchOption.AllDirectories);
                for (int i = 0; i < Math.Min(UpFolderStackHeight - nbFound, images.Length); i++) {
                    imagesToDraw.Insert(0, images[rnd.Next(images.Length)]);
                }
            }
            int drawXOffset = size / 2;
            int drawYOffset = size / 2;
            double angleAmplitude = Math.PI / 10;
            int imageFolderSize = (int)(size / (Math.Cos(angleAmplitude) + Math.Sin(angleAmplitude)));

            foreach (string folderImagePath in imagesToDraw) {
                Bitmap folderImage = new Bitmap(folderImagePath);

                int width = folderImage.Width;
                int height = folderImage.Height;
                if (imageFolderSize > 0 && folderImage.Width >= folderImage.Height && folderImage.Width > imageFolderSize) {
                    width = imageFolderSize;
                    height = imageFolderSize * folderImage.Height / folderImage.Width;
                }
                else if (imageFolderSize > 0 && folderImage.Height >= folderImage.Width && folderImage.Height > imageFolderSize) {
                    width = imageFolderSize * folderImage.Width / folderImage.Height;
                    height = imageFolderSize;
                }

                Pen UpFolderBorderPen = new Pen(new SolidBrush(UpFolderBorderColor), UpFolderBorderWidth);
                UpFolderBorderPen.LineJoin = LineJoin.Round;
                UpFolderBorderPen.StartCap = LineCap.Round;
                UpFolderBorderPen.EndCap = LineCap.Round;

                double angle = (0.5 - rnd.NextDouble()) * angleAmplitude;
                float sin = (float)Math.Sin(angle);
                float cos = (float)Math.Cos(angle);
                float sh = sin * height / 2;
                float ch = cos * height / 2;
                float sw = sin * width / 2;
                float cw = cos * width / 2;
                float shb = sin * (height + UpFolderBorderPen.Width) / 2;
                float chb = cos * (height + UpFolderBorderPen.Width) / 2;
                float swb = sin * (width + UpFolderBorderPen.Width) / 2;
                float cwb = cos * (width + UpFolderBorderPen.Width) / 2;

                g.DrawPolygon(UpFolderBorderPen, new PointF[] {
                new PointF(
                    (float)drawXOffset - cwb - shb,
                    (float)drawYOffset + chb - swb),
                new PointF(
                    (float)drawXOffset - cwb + shb,
                    (float)drawYOffset - swb - chb),
                new PointF(
                    (float)drawXOffset + cwb + shb,
                    (float)drawYOffset + swb - chb),
                new PointF(
                    (float)drawXOffset + cwb - shb,
                    (float)drawYOffset + swb + chb)
            });

                g.DrawImage(folderImage, new PointF[] {
                new PointF(
                    (float)drawXOffset - cw + sh,
                    (float)drawYOffset - sw - ch),
                new PointF(
                    (float)drawXOffset + cw + sh,
                    (float)drawYOffset + sw - ch),
                new PointF(
                    (float)drawXOffset - cw - sh,
                    (float)drawYOffset + ch - sw)
            });
                folderImage.Dispose();
            }

            if (isParentFolder) {
                Pen UpArrowPen = new Pen(new SolidBrush(UpArrowColor), UpArrowWidth);
                UpArrowPen.LineJoin = LineJoin.Round;
                UpArrowPen.StartCap = LineCap.Flat;
                UpArrowPen.EndCap = LineCap.Round;

                g.DrawLines(UpArrowPen, new PointF[] {
                new PointF((float)drawXOffset - UpArrowSize * size, (float)drawYOffset + UpArrowSize * size),
                new PointF((float)drawXOffset + UpArrowSize * size, (float)drawYOffset + UpArrowSize * size),
                new PointF((float)drawXOffset + UpArrowSize * size, (float)drawYOffset - UpArrowSize * size),
                new PointF((float)drawXOffset + UpArrowSize * size * 2 / 3, (float)drawYOffset - UpArrowSize * size * 2 / 3),
                new PointF((float)drawXOffset + UpArrowSize * size, (float)drawYOffset - UpArrowSize * size),
                new PointF((float)drawXOffset + UpArrowSize * size * 4 / 3, (float)drawYOffset - UpArrowSize * size * 2 / 3)
            });
            }

            g.Dispose();
            return newImage;
        }

        /// <summary>
        /// Gets the JPEG codec.
        /// </summary>
        /// <returns>The JPEG codec.</returns>
        static ImageCodecInfo GetImageCodec() {
            ImageCodecInfo codec = null;
            ImageCodecInfo[] encoders = ImageCodecInfo.GetImageEncoders();

            foreach (ImageCodecInfo e in encoders) {
                if (e.MimeType == "image/jpeg") {
                    codec = e;
                    break;
                }
            }

            return codec;
        }

        /// <summary>
        /// Returns the encoder parameters.
        /// </summary>
        /// <returns></returns>
        static EncoderParameters GetImageEncoderParams() {
            EncoderParameters encoderParams = new EncoderParameters();
            encoderParams.Param[0] = new EncoderParameter(Encoder.Quality, ThumbnailJpegQuality);
            return encoderParams;
        }

        /// <summary>
        /// Writes an image on the response.
        /// </summary>
        /// <param name="newImage">The Bitmap to write.</param>
        /// <param name="response">The HttpResponse to write to.</param>
        static void WriteNewImage(Bitmap newImage, HttpResponse response) {
            ImageCodecInfo codec = GetImageCodec();
            EncoderParameters encoderParams = GetImageEncoderParams();

            response.ContentType = "image/jpeg";
            newImage.Save(response.OutputStream, codec, encoderParams);

            encoderParams.Dispose();
        }

        /// <summary>
        /// Writes an image to the response.
        /// </summary>
        /// <param name="path">The path of the file.</param>
        /// <param name="response">The HttpResponse to write to.</param>
        static void WriteNewImage(string path, HttpResponse response) {
            response.ContentType = "image/jpeg";
            response.TransmitFile(path);
        }

        /// <summary>
        /// Writes a byte array to the response.
        /// </summary>
        /// <param name="imageBytes">The bytes to write</param>
        /// <param name="response">The HttpResponse to write to.</param>
        static void WriteNewImage(byte[] imageBytes, HttpResponse response) {
            response.ContentType = "image/jpeg";
            response.OutputStream.Write(imageBytes, 0, imageBytes.Length);
        }

        /// <summary>
        /// Gets an array of bytes from a Bitmap.
        /// </summary>
        /// <param name="image">The Bitmap.</param>
        /// <returns>The byte array.</returns>
        static byte[] GetImageBytes(Bitmap image) {
            ImageCodecInfo codec = GetImageCodec();
            EncoderParameters encoderParams = GetImageEncoderParams();

            MemoryStream ms = new MemoryStream();
            image.Save(ms, codec, encoderParams);
            ms.Close();

            encoderParams.Dispose();
            return ms.ToArray();
        }
    }

    /// <summary>
    /// The display modes or views for the Album Handler.
    /// </summary>
    public enum AlbumHandlerMode {
        /// <summary>
        /// Unknown mode.
        /// </summary>
        Unknown = 0,
        /// <summary>
        /// Displays the contents of a folder.
        /// </summary>
        Folder = 1,
        /// <summary>
        /// Displays the preview page for an image.
        /// </summary>
        Page = 2,
        /// <summary>
        /// Returns the reduced image used in the preview page.
        /// </summary>
        Preview = 3,
        /// <summary>
        /// Returns an image thumbnail.
        /// </summary>
        Thumbnail = 4,
        /// <summary>
        /// Returns a folder thumbnail.
        /// </summary>
        FolderThumbnail = 5,
        /// <summary>
        /// Returns a parent folder thumbnail.
        /// </summary>
        ParentThumbnail = 6,
        /// <summary>
        /// Returns the CSS stylesheet.
        /// </summary>
        Css = 7
    }

    /// <summary>
    /// Storing location for the cached preview and thumbnail images.
    /// </summary>
    public enum CacheLocation {
        /// <summary>
        /// Cached images are stored on disk in the application's compilation folder.
        /// </summary>
        Disk,
        /// <summary>
        /// Images are cached in memory.
        /// </summary>
        Memory,
        /// <summary>
        /// No caching. Images are redrawn on every request.
        /// </summary>
        None
    }

    /// <summary>
    /// Navigation mode when the album is used as a control.
    /// </summary>
    public enum NavigationMode {
        /// <summary>
        /// The default, this mode uses callbacks to refresh the album
        /// without navigating away from the page or posting back.
        /// Ifthe browser does not support callbacks, the control will post back.
        /// </summary>
        Callback,
        /// <summary>
        /// This mode uses form post backs to navigate in the album.
        /// </summary>
        Postback,
        /// <summary>
        /// Uses regular links to navigate in the album.
        /// May have side-effects on the rest of the page,
        /// which may have its own state management.
        /// </summary>
        Link
    }

    /// <summary>
    /// A template container for the album handler.
    /// </summary>
    public sealed class AlbumTemplateContainer : Control, INamingContainer, IDataItemContainer {
        private Album _owner;

        /// <summary>
        /// Constructs a template container for an Album.
        /// </summary>
        /// <param name="owner">The Album that owns this template.</param>
        public AlbumTemplateContainer(Album owner) {
            _owner = owner;
        }

        /// <summary>
        /// The Album that owns this template.
        /// </summary>
        public Album Owner {
            get {
                return _owner;
            }
        }

        /// <summary>
        /// The DataItem is the owner Album.
        /// </summary>
        object IDataItemContainer.DataItem {
            get { return Owner; }
        }

        /// <summary>
        /// The templates are single items, so the index is always zero.
        /// </summary>
        int IDataItemContainer.DataItemIndex {
            get { return 0; }
        }

        /// <summary>
        /// The templates are single items, so the index is always zero.
        /// </summary>
        int IDataItemContainer.DisplayIndex {
            get { return 0; }
        }
    }

    /// <summary>
    /// Base for classes that describe an album page
    /// </summary>
    public abstract class AlbumPageInfo {
        private Album _owner;
        private string _path;

        private string _link;
        private string _permalink;

        /// <summary>
        /// Constructs an AlbumPageInfo.
        /// </summary>
        /// <param name="owner">The Album that owns this info.</param>
        /// <param name="path">The virtual path of the page.</param>
        public AlbumPageInfo(Album owner, string path) {
            _owner = owner;
            _path = path;
        }

        /// <summary>
        /// The Album that owns this page.
        /// </summary>
        public Album Owner {
            get {
                return _owner;
            }
        }

        /// <summary>
        /// The virtual path to the page.
        /// </summary>
        public string Path {
            get {
                return _path;
            }
        }

        /// <summary>
        /// The character used as a command for this type of album page
        /// </summary>
        protected abstract char CommandCharacter { get; }

        /// <summary>
        /// The AlbumHandlerMode for this type of pages
        /// </summary>
        protected abstract AlbumHandlerMode AlbumMode { get; }

        /// <summary>
        /// A javascript link (callback if the browser supports it, postback otherwise) to this album page.
        /// </summary>
        public string Link {
            get {
                if (_link == null) {
                    if (!_owner.IsControl || _owner.NavigationMode == NavigationMode.Link) {
                        _link = PermaLink;
                    }
                    else {
                        string dirPrefix = _owner.PathPrefix;
                        string arg = CommandCharacter + _path;
                        if (_owner.NavigationMode == NavigationMode.Callback &&
                            HttpContext.Current.Request.Browser.SupportsCallback) {

                            _owner.Page.ClientScript.RegisterForEventValidation(_owner.UniqueID, arg);
                            _link = "javascript:" + _owner.Page.ClientScript.GetCallbackEventReference(
                                _owner,
                                '\'' + ImageHelper.JScriptEncode(arg) + '\'',
                                Album.CallbackFunction,
                                '\'' + _owner.ClientID + '\'', false);
                        }
                        else {
                            _link = _owner.Page.ClientScript.GetPostBackClientHyperlink(_owner, arg, true);
                        }
                    }
                }
                return _link;
            }
        }
        
        /// <summary>
        /// A permanent link to this image's preview page.
        /// </summary>
        public string PermaLink {
            get {
                if (_permalink == null) {
                    _permalink = ((_owner.Page != null) ?
                        _owner.ResolveClientUrl(_owner.Page.AppRelativeVirtualPath) :
                        String.Empty) +
                        "?albummode=" + AlbumMode + "&albumpath=" + HttpUtility.UrlEncode(_path);
                }
                return _permalink;
            }
        }
    }
    
    /// <summary>
    /// Describes an album folder.
    /// </summary>
    public sealed class AlbumFolderInfo : AlbumPageInfo {
        private bool _isParent;

        private string _name;

        /// <summary>
        /// Constructs an AlbumFolderInfo.
        /// </summary>
        /// <param name="owner">The Album that owns this info.</param>
        /// <param name="path">The virtual path of the folder.</param>
        /// <param name="isParent">True if the folder decribes the parent of the current Album view.</param>
        public AlbumFolderInfo(Album owner, string path, bool isParent)
            : this(owner, path) {
            _isParent = isParent;
        }

        /// <summary>
        /// Constructs an AlbumFolderInfo.
        /// </summary>
        /// <param name="owner">The Album that owns this info.</param>
        /// <param name="path">The virtual path of the folder.</param>
        public AlbumFolderInfo(Album owner, string path) 
            : base(owner, path) {}

        protected override char CommandCharacter {
            get {
                return Album.FolderCommand;
            }
        }

        protected override AlbumHandlerMode AlbumMode {
            get {
                return AlbumHandlerMode.Folder;
            }
        }
        
        /// <summary>
        /// The icon URL for the folder.
        /// </summary>
        public string IconUrl {
            get {
                return Owner.FilePath +
                    (_isParent ? "?albummode=parentthumbnail&albumpath=" : "?albummode=FolderThumbnail&albumpath=") +
                    HttpUtility.UrlEncode(Path);
            }
        }

        /// <summary>
        /// True if the folder is the parent of the current view.
        /// </summary>
        public bool IsParent {
            get {
                return _isParent;
            }
        }

        /// <summary>
        /// The name of this folder.
        /// </summary>
        public string Name {
            get {
                if (_name == null) {
                    _name = Path.Substring(Path.LastIndexOf('/') + 1);
                }
                return _name;
            }
        }
    }

    /// <summary>
    /// Describes an Album image.
    /// </summary>
    public sealed class ImageInfo : AlbumPageInfo {
        private string _physicalPath;

        private string _name;

        /// <summary>
        /// Constructs an ImageInfo.
        /// </summary>
        /// <param name="owner">The Album that owns this image.</param>
        /// <param name="path">The virtual path of the image.</param>
        /// <param name="physicalPath">The physical path of the image.</param>
        public ImageInfo(Album owner, string path, string physicalPath)
            : base(owner, path) {
            _physicalPath = physicalPath;
        }

        protected override char CommandCharacter {
            get {
                return Album.PageCommand;
            }
        }

        protected override AlbumHandlerMode AlbumMode {
            get {
                return AlbumHandlerMode.Page;
            }
        }

        /// <summary>
        /// The image caption.
        /// It is the name if available from the ITPC meta-data, or the file name.
        /// </summary>
        public string Caption {
            get {
                if (_name == null) {
                    FileInfo pictureFileInfo = new FileInfo(_physicalPath);
                    Metadata data = GetImageData(pictureFileInfo);
                    IptcDirectory iptcDir = (IptcDirectory)data.GetDirectory(typeof(IptcDirectory));
                    if (iptcDir.ContainsTag(IptcDirectory.TAG_OBJECT_NAME)) {
                        _name = iptcDir.GetString(IptcDirectory.TAG_OBJECT_NAME);
                    }
                    else {
                        _name = System.IO.Path.GetFileNameWithoutExtension(_physicalPath);
                    }
                }
                return _name;
            }
        }

        /// <summary>
        /// The date the image was created.
        /// </summary>
        public DateTime Date {
            get {
                return GetImageDate(new FileInfo(_physicalPath));
            }
        }

        /// <summary>
        /// The URL of the thumbnail for this image.
        /// </summary>
        public string IconUrl {
            get {
                return Owner.FilePath +
                    "?albummode=Thumbnail&albumpath=" +
                    HttpUtility.UrlEncode(Path);
            }
        }

        /// <summary>
        /// The metadata for this image.
        /// </summary>
        public Dictionary<string, List<KeyValuePair<string, string>>> MetaData {
            get {
                Metadata data = GetImageData(new FileInfo(_physicalPath));
                Dictionary<string, List<KeyValuePair<string, string>>> dict =
                    new Dictionary<string, List<KeyValuePair<string, string>>>(data.GetDirectoryCount());
                IEnumerator dirs = data.GetDirectoryIterator();
                while (dirs.MoveNext()) {
                    MetadataDirectory dir = (MetadataDirectory)dirs.Current;
                    List<KeyValuePair<string, string>> properties =
                        new List<KeyValuePair<string, string>>(dir.GetTagCount());
                    dict.Add(dir.GetName(), properties);
                    IEnumerator tags = dir.GetTagIterator();
                    while (tags.MoveNext()) {
                        string name = String.Empty;
                        string description = String.Empty;
                        try {
                            Tag tag = (Tag)tags.Current;
                            name = tag.GetTagName();
                            description = tag.GetDescription();
                        }
                        catch { }
                        if (!String.IsNullOrEmpty(description) &&
                            !String.IsNullOrEmpty(name) &&
                            !name.StartsWith("Unknown ") &&
                            !name.StartsWith("Makernote Unknown ") &&
                            !description.StartsWith("Unknown (\"")) {
                            
                            properties.Add(new KeyValuePair<string,string>(name, description));
                        }
                    }
                }
                return dict;
            }
        }

        /// <summary>
        /// The URL of the preview image for this image.
        /// </summary>
        public string PreviewUrl {
            get {
                return Owner.FilePath +
                    "?albummode=Preview&albumpath=" +
                    HttpUtility.UrlEncode(Path);
            }
        }

        /// <summary>
        /// The virtual path of the full resolution image.
        /// </summary>
        public string Url {
            get {
                return Path;
            }
        }

        /// <summary>
        /// Extracts and caches the metadata for an image.
        /// </summary>
        /// <param name="pictureFileInfo">The FileInfo to the image.</param>
        /// <returns>The MetaData for the image.</returns>
        internal static Metadata GetImageData(FileInfo pictureFileInfo) {
            string cacheKey = "data(" + pictureFileInfo.FullName + ")";
            Cache cache = HttpContext.Current.Cache;
            object cached = cache[cacheKey];
            if (cached == null) {
                Metadata data = new Metadata();
                ExifReader exif = new ExifReader(pictureFileInfo);
                exif.Extract(data);
                IptcReader iptc = new IptcReader(pictureFileInfo);
                iptc.Extract(data);
                JpegReader jpeg = new JpegReader(pictureFileInfo);
                jpeg.Extract(data);
                cache.Insert(cacheKey, data, new CacheDependency(pictureFileInfo.FullName));
                return data;
            }
            return (Metadata)cached;
        }

        /// <summary>
        /// Gets and caches the most relevant date available for an image.
        /// It looks first at the EXIF date, then at the creation date from ITPC data,
        /// and then at the file's creation date if everything else failed.
        /// </summary>
        /// <param name="pictureFileInfo">The FileInfo for the image.</param>
        /// <returns>The date.</returns>
        internal static DateTime GetImageDate(FileInfo pictureFileInfo) {
            string cacheKey = "date(" + pictureFileInfo.FullName + ")";
            Cache cache = HttpContext.Current.Cache;
            DateTime result = DateTime.MinValue;
            object cached = cache[cacheKey];
            if (cached == null) {
                Metadata data = GetImageData(pictureFileInfo);
                ExifDirectory directory = (ExifDirectory)data.GetDirectory(typeof(ExifDirectory));
                if (directory.ContainsTag(ExifDirectory.TAG_DATETIME)) {
                    try {
                        result = directory.GetDate(ExifDirectory.TAG_DATETIME);
                    }
                    catch { }
                }
                else {
                    IptcDirectory iptcDir = (IptcDirectory)data.GetDirectory(typeof(IptcDirectory));
                    if (iptcDir.ContainsTag(IptcDirectory.TAG_DATE_CREATED)) {
                        try {
                            result = iptcDir.GetDate(IptcDirectory.TAG_DATE_CREATED);
                        }
                        catch { }
                    }
                    else {
                        result = pictureFileInfo.CreationTime;
                    }
                }
                cache.Insert(cacheKey, result, new CacheDependency(pictureFileInfo.FullName));
            }
            else {
                result = (DateTime)cached;
            }
            return result;
        }
    }

    /// <summary>
    /// The photo album handler.
    /// This class can act as an HttpHandler or as a Control.
    /// </summary>
    public sealed class Album : UserControl, IHttpHandler, IPostBackEventHandler, ICallbackEventHandler {
        private const string AlbumScript = @"
function photoAlbumDetails(id) {
    var details = document.getElementById(id + '_details');
    if (details.style.display && details.style.display == 'none') {
        details.style.display = 'block';
    }
    else {
        details.style.display = 'none';
    }
}
";

        private const string CallbackScript = @"
function photoAlbumCallback(result, context) {
    var album = document.getElementById(context);
    if (album) {
        album.innerHTML = result;
    }            
}
";
        
        internal const string CallbackFunction = "photoAlbumCallback";

        internal const char FolderCommand = 'f';
        internal const char PageCommand = 'p';
        
        private HttpRequest _request;
        private HttpResponse _response;

        private string _requestPathPrefix;
        private string _requestDir;

        private AlbumHandlerMode _mode;
        private bool _isControl;
        private string _filePath;
        private string _rawPath;
        private string _physicalPath;
        private string _title;
        private string _description;

        private ITemplate _folderModeTemplate;
        private ITemplate _pageModeTemplate;

        private ImageInfo _image;
        private AlbumFolderInfo _parentFolder;
        private ImageInfo _previousImage;
        private ImageInfo _nextImage;

        /// <summary>
        /// The tooltip for going back to the folder view from the image preview.
        /// </summary>
        [Localizable(true), DefaultValue("Go back to folder view")]
        public string BackToFolderViewTooltip {
            get {
                string s = ViewState["BackToFolderViewTooltip"] as string;
                return (s == null) ? "Go back to folder view" : s;
            }
            set {
                ViewState["BackToFolderViewTooltip"] = value;
            }
        }

        /// <summary>
        /// The text of the back to parent link.
        /// </summary>
        [Localizable(true), DefaultValue("Up")]
        public string BackToParentText {
            get {
                string s = ViewState["BackToParentText"] as string;
                return (s == null) ? "Up" : s;
            }
            set {
                ViewState["BackToParentText"] = value;
            }
        }

        /// <summary>
        /// Tooltip for going back to the parent folder.
        /// </summary>
        [Localizable(true), DefaultValue("Click to go back to the parent folder")]
        public string BackToParentTooltip {
            get {
                string s = ViewState["BackToParentTooltip"] as string;
                return (s == null) ? "Click to go back to the parent folder" : s;
            }
            set {
                ViewState["BackToParentTooltip"] = value;
            }
        }

        /// <summary>
        /// The top CSS class for the control.
        /// </summary>
        [DefaultValue("album")]
        public string CssClass {
            get {
                string s = ViewState["CssClass"] as string;
                return (s == null) ? "album" : s;
            }
            set {
                ViewState["CssClass"] = value;
            }
        }

        /// <summary>
        /// The CSS class for the details (meta-data) link in the preview pages.
        /// </summary>
        [DefaultValue("albumDetailsLink")]
        public string DetailsLinkCssClass {
            get {
                string s = ViewState["DetailsLinkCssClass"] as string;
                return (s == null) ? "albumDetailsLink" : s;
            }
            set {
                ViewState["DetailsLinkCssClass"] = value;
            }
        }

        /// <summary>
        /// The text for the details (meta-data) link in the preview pages.
        /// </summary>
        [Localizable(true), DefaultValue("Details")]
        public string DetailsText {
            get {
                string s = ViewState["DetailsText"] as string;
                return (s == null) ? "Details" : s;
            }
            set {
                ViewState["DetailsText"] = value;
            }
        }

        /// <summary>
        /// The tooltip for displaying the preview page.
        /// </summary>
        [Localizable(true), DefaultValue("Click to display")]
        public string DisplayImageTooltip {
            get {
                string s = ViewState["DisplayImageTooltip"] as string;
                return (s == null) ? "Click to display" : s;
            }
            set {
                ViewState["DisplayImageTooltip"] = value;
            }
        }

        /// <summary>
        /// Tooltip for seeing the image at full resolution.
        /// </summary>
        [Localizable(true), DefaultValue("Click to view picture at full resolution")]
        public string DisplayFullResolutionTooltip {
            get {
                string s = ViewState["DisplayFullResolutionTooltip"] as string;
                return (s == null) ? "Click to view picture at full resolution" : s;
            }
            set {
                ViewState["DisplayFullResolutionTooltip"] = value;
            }
        }

        /// <summary>
        /// The path of the current file.
        /// </summary>
        internal string FilePath {
            get {
                return _filePath;
            }
        }

        /// <summary>
        /// The template for the folder mode.
        /// </summary>
        [PersistenceMode(PersistenceMode.InnerProperty), TemplateContainer(typeof(AlbumTemplateContainer))]
        public ITemplate FolderModeTemplate {
            get {
                return _folderModeTemplate;
            }
            set {
                _folderModeTemplate = value;
            }
        }

        /// <summary>
        /// The URL of the handler.
        /// </summary>
        [DefaultValue("~/album.ashx"), UrlProperty]
        public string HandlerUrl {
            get {
                string s = ViewState["HandlerUrl"] as string;
                return (s == null) ? "~/album.ashx" : s;
            }
            set {
                ViewState["HandlerUrl"] = value;
            }
        }

        /// <summary>
        /// The info for the current image.
        /// </summary>
        public ImageInfo Image {
            get {
                if (_mode == AlbumHandlerMode.Page) {
                    if (_image == null) {
                        _image = new ImageInfo(this, Path, _physicalPath);
                    }
                    return _image;
                }
                return null;
            }
        }

        /// <summary>
        /// The CSS class for a thumbnail.
        /// </summary>
        [DefaultValue("albumFloat")]
        public string ImageDivCssClass {
            get {
                string s = ViewState["ImageDivCssClass"] as string;
                return (s == null) ? "albumFloat" : s;
            }
            set {
                ViewState["ImageDivCssClass"] = value;
            }
        }

        /// <summary>
        /// The list of image infos for the current folder.
        /// </summary>
        public List<ImageInfo> Images {
            get {
                if (_mode == AlbumHandlerMode.Folder) {
                    FileInfo[] pics = GetImages(_physicalPath);
                    List<ImageInfo> images = null;
                    if (pics != null && pics.Length > 0) {
                        string dirPrefix = Path;
                        if (!dirPrefix.EndsWith("/")) {
                            dirPrefix += "/";
                        }
                        images = new List<ImageInfo>(pics.Length);
                        foreach (FileInfo f in pics) {
                            string picName = f.Name;
                            images.Add(new ImageInfo(this, dirPrefix + picName, f.FullName));
                        }
                    }
                    return images;
                }
                return null;
            }
        }

        /// <summary>
        /// True if the class is used in Control mode (as opposed to handler mode).
        /// </summary>
        internal bool IsControl {
            get {
                return _isControl;
            }
        }

        /// <summary>
        /// CSS class for metadata field names.
        /// </summary>
        [DefaultValue("albumMetaName")]
        public string MetaNameCssClass {
            get {
                string s = ViewState["MetaNameCssClass"] as string;
                return (s == null) ? "albumMetaName" : s;
            }
            set {
                ViewState["MetaNameCssClass"] = value;
            }
        }

        /// <summary>
        /// CSS class for metadata section heads.
        /// </summary>
        [DefaultValue("albumMetaSectionHead")]
        public string MetaSectionHeadCssClass {
            get {
                string s = ViewState["MetaSectionHeadCssClass"] as string;
                return (s == null) ? "albumMetaSectionHead" : s;
            }
            set {
                ViewState["MetaSectionHeadCssClass"] = value;
            }
        }

        /// <summary>
        /// CSS class for metadata values.
        /// </summary>
        [DefaultValue("albumMetaValue")]
        public string MetaValueCssClass {
            get {
                string s = ViewState["MetaValueCssClass"] as string;
                return (s == null) ? "albumMetaValue" : s;
            }
            set {
                ViewState["MetaValueCssClass"] = value;
            }
        }

        /// <summary>
        /// Defines how the Album navigation links work.
        /// </summary>
        [DefaultValue(NavigationMode.Callback)]
        public NavigationMode NavigationMode {
            get {
                object o = ViewState["NavigationMode"];
                return (o == null) ? NavigationMode.Callback : (NavigationMode)o;
            }
            set {
                ViewState["NavigationMode"] = value;
            }
        }

        /// <summary>
        /// Info for the next image.
        /// </summary>
        public ImageInfo NextImage {
            get {
                if (_mode == AlbumHandlerMode.Page) {
                    if (_nextImage == null) {
                        EnsureNextPrevious();
                    }
                    return _nextImage;
                }
                return null;
            }
        }

        /// <summary>
        /// Tooltip for the link to the next image.
        /// </summary>
        [Localizable(true), DefaultValue("Click to view the next picture")]
        public string NextImageTooltip {
            get {
                string s = ViewState["NextImageTooltip"] as string;
                return (s == null) ? "Click to view the next picture" : s;
            }
            set {
                ViewState["NextImageTooltip"] = value;
            }
        }

        /// <summary>
        /// Format string for the open folder tooltip.
        /// </summary>
        [Localizable(true), DefaultValue(@"Click to open ""{0}""")]
        public string OpenFolderTooltipFormatString {
            get {
                string s = ViewState["OpenFolderTooltipFormatString"] as string;
                return (s == null) ? @"Click to open ""{0}""" : s;
            }
            set {
                ViewState["OpenFolderTooltipFormatString"] = value;
            }
        }

        /// <summary>
        /// Template for the control in image preview mode.
        /// </summary>
        [PersistenceMode(PersistenceMode.InnerProperty), TemplateContainer(typeof(AlbumTemplateContainer))]
        public ITemplate PageModeTemplate {
            get {
                return _pageModeTemplate;
            }
            set {
                _pageModeTemplate = value;
            }
        }

        /// <summary>
        /// Information for the parent folder.
        /// </summary>
        public AlbumFolderInfo ParentFolder {
            get {
                if (_parentFolder == null) {
                    if (Path != "/") {
                        int i = Path.LastIndexOf('/');
                        string parentDirPath;

                        if (i == 0) {
                            parentDirPath = "/";
                        }
                        else {
                            parentDirPath = Path.Substring(0, i);
                        }

                        if (parentDirPath == _requestDir || parentDirPath.StartsWith(_requestPathPrefix)) {
                            _parentFolder = new AlbumFolderInfo(this, parentDirPath, true);
                        }
                    }
                }
                return _parentFolder;
            }
        }

        /// <summary>
        /// The current virtual path.
        /// </summary>
        [DefaultValue("")]
        public string Path {
            get {
                string s = ViewState["Path"] as string;
                return (s == null) ? String.Empty : s;
            }
            set {
                _rawPath = value;
                string path = null;
                if (value != null) {
                    path = value.ToLower().Replace("\\", "/").Trim();

                    if (path != "/" && path.EndsWith("/")) {
                        path = path.Substring(0, path.Length - 1);
                    }

                    if (path != _requestDir && !path.StartsWith(_requestPathPrefix)) {
                        ReportError("invalid path - not in the handler scope");
                    }

                    if (path.IndexOf("/.") >= 0) {
                        ReportError("invalid path");
                    }
                }
                else {
                    path = _requestDir;
                    _rawPath = _requestDir;
                }
                ViewState["Path"] = path;

                _physicalPath = _request.MapPath(path, "/", false);
            }
        }

        /// <summary>
        /// The fixed part of the path.
        /// </summary>
        internal string PathPrefix {
            get {
                return _requestPathPrefix;
            }
        }

        /// <summary>
        /// A permanent link to the current page with the Album in its current state.
        /// </summary>
        public string PermaLink {
            get {
                return ResolveClientUrl(Page.AppRelativeVirtualPath) +
                        "?albummode=" + _mode.ToString() +
                        "&albumpath=" + HttpUtility.UrlEncode(_rawPath);
            }
        }

        /// <summary>
        /// The information for the previous image.
        /// </summary>
        public ImageInfo PreviousImage {
            get {
                if (_mode == AlbumHandlerMode.Page) {
                    if (_previousImage == null) {
                        EnsureNextPrevious();
                    }
                    return _previousImage;
                }
                return null;
            }
        }
        
        /// <summary>
        /// The tooltip for the link to the previous image.
        /// </summary>
        [Localizable(true), DefaultValue("Click to view the previous picture")]
        public string PreviousImageTooltip {
            get {
                string s = ViewState["PreviousImageTooltip"] as string;
                return (s == null) ? "Click to view the previous picture" : s;
            }
            set {
                ViewState["PreviousImageTooltip"] = value;
            }
        }

        /// <summary>
        /// The subfolders of the current folder.
        /// </summary>
        public List<AlbumFolderInfo> SubFolders {
            get {
                if (_mode == AlbumHandlerMode.Folder) {
                    string[] dirs = Directory.GetDirectories(_physicalPath);
                    List<AlbumFolderInfo> subFolders = null;
                    if (dirs != null && dirs.Length > 0) {
                        subFolders = new List<AlbumFolderInfo>(dirs.Length);
                        string dirPrefix = Path;
                        if (!dirPrefix.EndsWith("/")) {
                            dirPrefix += "/";
                        }
                        foreach (string d in dirs) {
                            string dirName = (new FileInfo(d)).Name;
                            string dir = dirName.ToLower();
                            if (dir.StartsWith("_vti_") ||
                                dir.StartsWith("app_") ||
                                (dir == "bin") ||
                                (dir == "aspnet_client")) {
                                continue;
                            }
                            subFolders.Add(new AlbumFolderInfo(this, dirPrefix + dirName));
                        }
                    }
                    return subFolders;
                }
                return null;
            }
        }

        /// <summary>
        /// The title for the current Album view.
        /// </summary>
        public string Title {
            get {
                if (_title == null) {
                    if (_mode == AlbumHandlerMode.Folder) {
                        _title = _rawPath.Substring(_rawPath.LastIndexOf('/') + 1);
                    }
                    else {
                        FileInfo pictureFileInfo = new FileInfo(_physicalPath);
                        Metadata data = ImageInfo.GetImageData(pictureFileInfo);
                        
                        // First, check for the IPTC Title tag
                        IptcDirectory iptcDir = (IptcDirectory)data.GetDirectory(typeof(IptcDirectory));
                        if (iptcDir.ContainsTag(IptcDirectory.TAG_OBJECT_NAME)) {
                            _title = iptcDir.GetString(IptcDirectory.TAG_OBJECT_NAME);
                        }
                        else {
                            // Then, try the Exif Title tag used by XP (in Property / Summary dialog)
                            ExifDirectory exifDir = (ExifDirectory)data.GetDirectory(typeof(ExifDirectory));
                            if (exifDir.ContainsTag(ExifDirectory.TAG_XP_TITLE)) {
                                _title = exifDir.GetDescription(ExifDirectory.TAG_XP_TITLE);
                            }
                            else {
                                // Default the title to teh file name
                                _title = System.IO.Path.GetFileNameWithoutExtension(_physicalPath);
                            }
                        }
                    }
                }
                return _title;
            }
        }

        /// <summary>
        /// The description for the current Album view.
        /// </summary>
        public string Description {
            get {
                if (_description == null) {
                    _description = String.Empty;
                    if (_mode == AlbumHandlerMode.Page) {
                        FileInfo pictureFileInfo = new FileInfo(_physicalPath);
                        Metadata data = ImageInfo.GetImageData(pictureFileInfo);

                        // Try the Exif Description tag used by XP (in Property / Summary dialog)
                        ExifDirectory exifDir = (ExifDirectory)data.GetDirectory(typeof(ExifDirectory));
                        if (exifDir.ContainsTag(ExifDirectory.TAG_XP_COMMENTS)) {
                            _description = exifDir.GetDescription(ExifDirectory.TAG_XP_COMMENTS);
                        }
                    }
                }

                return _description;
            }
        }

        protected override void CreateChildControls() {
            if ((FolderModeTemplate != null) && (_mode == AlbumHandlerMode.Folder)) {
                Controls.Clear();
                _parentFolder = null;
                AlbumTemplateContainer container = new AlbumTemplateContainer(this);
                container.EnableViewState = false;
                FolderModeTemplate.InstantiateIn(container);
                Controls.Add(container);
            }
            if ((PageModeTemplate != null) && (_mode == AlbumHandlerMode.Page)) {
                Controls.Clear();
                _image = null;
                AlbumTemplateContainer container = new AlbumTemplateContainer(this);
                container.EnableViewState = false;
                PageModeTemplate.InstantiateIn(container);
                Controls.Add(container);
            }
        }

        /// <summary>
        /// Ensures that the next and previous image infos have been computed.
        /// </summary>
        private void EnsureNextPrevious() {
            bool pictureFound = false;
            string dirPath = System.IO.Path.GetDirectoryName(_physicalPath);
            FileInfo[] pics = GetImages(dirPath);

            string prev = null;
            string next = null;
            string prevPhysPath = null;
            string nextPhysPath = null;
            string parentPath = ParentFolder.Path;
            
            if (pics != null && pics.Length > 0) {
                foreach (FileInfo p in pics) {
                    string picture = p.Name.ToLower();

                    if (String.Equals(p.FullName, _physicalPath, StringComparison.InvariantCultureIgnoreCase)) {
                        pictureFound = true;
                    }
                    else if (pictureFound) {
                        nextPhysPath = p.FullName;
                        next = parentPath + '/' + picture;
                        break;
                    }
                    else {
                        prevPhysPath = p.FullName;
                        prev = parentPath + '/' + picture;
                    }
                }
            }

            if (!pictureFound) {
                prevPhysPath = null;
                nextPhysPath = null;
            }
            if (prev != null) {
                _previousImage = new ImageInfo(this, prev, prevPhysPath);
            }
            if (next != null) {
                _nextImage = new ImageInfo(this, next, nextPhysPath);
            }
        }
        
        protected override void OnInit(EventArgs e) {
            base.OnInit(e);
            _isControl = true;
            _filePath = Page.ResolveUrl(HandlerUrl);
            _requestPathPrefix = _filePath.Substring(0, _filePath.LastIndexOf('/') + 1).ToLower();

            _requestDir = (_requestPathPrefix == "/") ?
                "/" :
                _requestPathPrefix.Substring(0, _requestPathPrefix.Length - 1);
            _request = Request;
            _response = Response;

            ParseParams();
            ChildControlsCreated = false;
        }
        
        protected override void OnPreRender(EventArgs e) {
            base.OnPreRender(e);
            Page.ClientScript.RegisterClientScriptBlock(typeof(Album), "AlbumScript", AlbumScript, true);
            if (Request.Browser.SupportsCallback) {
                Page.ClientScript.RegisterClientScriptBlock(typeof(Album), "CallbackScript", CallbackScript, true);
            }
        }

        public override void RenderControl(HtmlTextWriter writer) {
            if (((FolderModeTemplate != null) && (_mode == AlbumHandlerMode.Folder)) ||
                ((PageModeTemplate != null) && (_mode == AlbumHandlerMode.Page))) {
                Controls[0].DataBind();
            }
            RenderPrivate(writer);
        }
        
        void IHttpHandler.ProcessRequest(HttpContext context) {
            _request = context.Request;
            _response = context.Response;

            RenderPrivate(new HtmlTextWriter(_response.Output));
        }

        /// <summary>
        /// Directs to the right rendering methos according to the mode.
        /// </summary>
        /// <param name="writer">The writer to write to.</param>
        private void RenderPrivate(HtmlTextWriter writer) {
            if (!_isControl) {
                _filePath = _request.FilePath;
                _requestPathPrefix = _filePath.Substring(0, _filePath.LastIndexOf('/') + 1).ToLower();

                _requestDir = (_requestPathPrefix == "/") ?
                    "/" :
                    _requestPathPrefix.Substring(0, _requestPathPrefix.Length - 1);

                ParseParams();
            }

            if ((_mode == AlbumHandlerMode.Folder) ||
                (_mode == AlbumHandlerMode.FolderThumbnail) ||
                (_mode == AlbumHandlerMode.ParentThumbnail)) {

                if (!Directory.Exists(_physicalPath)) {
                    throw new HttpException(404, "Directory Not Found");
                }
            }
            else if ((_mode != AlbumHandlerMode.Css) && !File.Exists(_physicalPath)) {
                throw new HttpException(404, "File Not Found");
            }

            switch (_mode) {
                case AlbumHandlerMode.Folder:
                    GenerateFolderPage(writer, Path, _physicalPath);
                    break;

                case AlbumHandlerMode.Page:
                    string dir = Path.Substring(0, Path.LastIndexOf('/') + 1);

                    if (dir != "/") {
                        dir = dir.Substring(0, dir.Length - 1);
                    }

                    GeneratePreviewPage(
                        writer,
                        dir,
                        _request.MapPath(dir),
                        Path.Substring(Path.LastIndexOf('/') + 1).ToLower());
                    break;

                case AlbumHandlerMode.Preview:
                    ImageHelper.GenerateResizedImageResponse(_physicalPath, ImageHelper.PreviewSize, false, _response);
                    break;

                case AlbumHandlerMode.Thumbnail:
                    ImageHelper.GenerateResizedImageResponse(_physicalPath, ImageHelper.ThumbnailSize, true, _response);
                    break;

                case AlbumHandlerMode.FolderThumbnail:
                    ImageHelper.GenerateFolderImageResponse(false, _physicalPath, ImageHelper.ThumbnailSize, _response);
                    break;

                case AlbumHandlerMode.ParentThumbnail:
                    ImageHelper.GenerateFolderImageResponse(true, _physicalPath, ImageHelper.ThumbnailSize, _response);
                    break;
                    
                case AlbumHandlerMode.Css:
                    ImageHelper.GenerateCssResponse(_response);
                    break;

                default:
                    ReportError("invalid mode");
                    break;
            }
        }

        bool IHttpHandler.IsReusable {
            get { return false; }
        }

        /// <summary>
        /// Does the actual rendering for the folder mode.
        /// </summary>
        /// <param name="writer">The writer to write to.</param>
        /// <param name="dirPath">The virtual path to the folder.</param>
        /// <param name="dirPhysicalPath">The physical for the folder.</param>
        void GenerateFolderPage(HtmlTextWriter writer, string dirPath, string dirPhysicalPath) {
            string dirPrefix = dirPath;
            if (!dirPrefix.EndsWith("/")) {
                dirPrefix += "/";
            }

            if (_isControl) {
                if (!Page.IsCallback) {
                    writer.AddAttribute(HtmlTextWriterAttribute.Id, ClientID);
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, CssClass);
                    writer.RenderBeginTag(HtmlTextWriterTag.Div);
                }
            }
            else {
                writer.Write(@"<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.1//EN"" ""http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"">");
                writer.AddAttribute("xmlns", "http://www.w3.org/1999/xhtml");
                writer.RenderBeginTag(HtmlTextWriterTag.Html);
                writer.RenderBeginTag(HtmlTextWriterTag.Head);
                writer.AddAttribute(HtmlTextWriterAttribute.Rel, "Stylesheet");
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/css");
                writer.AddAttribute(HtmlTextWriterAttribute.Href, "?albummode=css");
                writer.RenderBeginTag(HtmlTextWriterTag.Link);
                writer.RenderEndTag(); // link
                writer.RenderBeginTag(HtmlTextWriterTag.Title);
                writer.WriteEncodedText(Title);
                writer.RenderEndTag(); // title
                writer.RenderEndTag(); // head
                writer.RenderBeginTag(HtmlTextWriterTag.Body);
            }

            if (FolderModeTemplate != null) {
                Controls[0].RenderControl(writer);
            }
            else {

                if (dirPath != "/") {
                    int i = dirPath.LastIndexOf('/');
                    string parentDirPath;

                    if (i == 0) {
                        parentDirPath = "/";
                    }
                    else {
                        parentDirPath = dirPath.Substring(0, i);
                    }

                    if (parentDirPath == _requestDir || parentDirPath.StartsWith(_requestPathPrefix)) {
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, ImageDivCssClass);
                        writer.RenderBeginTag(HtmlTextWriterTag.Div);
                        writer.AddAttribute(HtmlTextWriterAttribute.Href, ParentFolder.Link, true);
                        writer.RenderBeginTag(HtmlTextWriterTag.A);
                        writer.AddAttribute(HtmlTextWriterAttribute.Src, ParentFolder.IconUrl, true);
                        writer.AddAttribute(HtmlTextWriterAttribute.Alt, BackToParentTooltip, true);
                        writer.RenderBeginTag(HtmlTextWriterTag.Img);
                        writer.RenderEndTag(); // img
                        writer.WriteBreak();
                        writer.Write(BackToParentText);
                        writer.RenderEndTag(); // a
                        writer.RenderEndTag(); // div
                    }
                }

                List<AlbumFolderInfo> folders = SubFolders;
                if (folders != null && folders.Count > 0) {
                    foreach (AlbumFolderInfo folder in folders) {
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, ImageDivCssClass);
                        writer.RenderBeginTag(HtmlTextWriterTag.Div);
                        writer.AddAttribute(HtmlTextWriterAttribute.Href, folder.Link, true);
                        writer.RenderBeginTag(HtmlTextWriterTag.A);
                        writer.AddAttribute(HtmlTextWriterAttribute.Src, folder.IconUrl, true);
                        writer.AddAttribute(HtmlTextWriterAttribute.Alt,
                            String.Format(OpenFolderTooltipFormatString, folder.Name), true);
                        writer.RenderBeginTag(HtmlTextWriterTag.Img);
                        writer.RenderEndTag(); // img
                        writer.WriteBreak();
                        writer.Write(folder.Name);
                        writer.RenderEndTag(); // a
                        writer.RenderEndTag(); // div
                    }
                }

                List<ImageInfo> images = Images;
                if (images != null && images.Count > 0) {
                    foreach (ImageInfo image in images) {
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, ImageDivCssClass);
                        writer.RenderBeginTag(HtmlTextWriterTag.Div);
                        writer.AddAttribute(HtmlTextWriterAttribute.Href, image.Link, true);
                        writer.RenderBeginTag(HtmlTextWriterTag.A);
                        writer.AddAttribute(HtmlTextWriterAttribute.Src, image.IconUrl, true);
                        writer.AddAttribute(HtmlTextWriterAttribute.Alt, DisplayImageTooltip, true);
                        writer.RenderBeginTag(HtmlTextWriterTag.Img);
                        writer.RenderEndTag(); // img
                        writer.RenderEndTag(); // a
                        writer.WriteBreak();
                        writer.Write("&nbsp;");
                        writer.RenderEndTag(); // div
                    }
                }
            }

            if (_isControl) {
                if (!Page.IsCallback) {
                    writer.RenderEndTag(); // div
                }
            }
            else {
                writer.RenderEndTag(); // body
                writer.RenderEndTag(); // html
            }
        }

        /// <summary>
        /// Gets an array of file infos for the images in a folder, sorted by date.
        /// </summary>
        /// <param name="path">The folder's physical path.</param>
        /// <returns>The list of file infos, sorted by date.</returns>
        private static FileInfo[] GetImages(string path) {
            return GetImages(path, false);
        }
        
        /// <summary>
        /// Gets an array of file infos for the images in a folder, sorted by date.
        /// </summary>
        /// <param name="path">The folder's physical path.</param>
        /// <param name="includesubFolders">True if subfolders should be included.</param>
        /// <returns>The list of file infos, sorted by date.</returns>
        private static FileInfo[] GetImages(string path, bool includesubFolders) {
            DirectoryInfo di = new DirectoryInfo(path);
            FileInfo[] pics = di.GetFiles("*.jpg",
                includesubFolders ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
            Array.Sort<FileInfo>(pics, delegate(FileInfo x, FileInfo y) {
                return ImageInfo.GetImageDate(x).CompareTo(ImageInfo.GetImageDate(y));
            });
            return pics;
        }

        /// <summary>
        /// Gets the top n images in a folder, sorted by date descending.
        /// </summary>
        /// <param name="numberOfImages">Maximum number of images to return.</param>
        /// <param name="includeSubFolders">True if subfolders should be included.</param>
        /// <returns>The image infos.</returns>
        public List<ImageInfo> GetImages(int numberOfImages, bool includeSubFolders) {
            if (_mode == AlbumHandlerMode.Folder) {
                FileInfo[] pics = GetImages(_physicalPath, includeSubFolders);
                List<ImageInfo> images = null;
                if (pics != null && pics.Length > 0) {
                    string dirPrefix = Path;
                    if (!dirPrefix.EndsWith("/")) {
                        dirPrefix += "/";
                    }
                    images = new List<ImageInfo>(numberOfImages);
                    int n = 1;
                    foreach (FileInfo f in pics) {
                        string picName = f.Name;
                        images.Add(new ImageInfo(this, dirPrefix + picName, f.FullName));
                        if (n++ >= numberOfImages) {
                            break;
                        }
                    }
                }
                return images;
            }
            return null;
        }

        /// <summary>
        /// Renders an image preview page.
        /// </summary>
        /// <param name="writer">The writer to render to.</param>
        /// <param name="dirPath">The virtual path of the directory.</param>
        /// <param name="dirPhysicalPath">The physical path of the directory.</param>
        /// <param name="page">The name of the image.</param>
        void GeneratePreviewPage(HtmlTextWriter writer, string dirPath, string dirPhysicalPath, string page) {
            string dirPrefix = dirPath;
            if (!dirPrefix.EndsWith("/")) {
                dirPrefix += "/";
            }
            
            string pictPath = dirPrefix + page;

            if (_isControl) {
                if (!Page.IsCallback) {
                    writer.AddAttribute(HtmlTextWriterAttribute.Id, ClientID);
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, CssClass);
                    writer.RenderBeginTag(HtmlTextWriterTag.Div);
                }
            }
            else {
                writer.Write(@"<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.1//EN"" ""http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"">");
                writer.AddAttribute("xmlns", "http://www.w3.org/1999/xhtml");
                writer.RenderBeginTag(HtmlTextWriterTag.Html);
                writer.RenderBeginTag(HtmlTextWriterTag.Head);
                writer.AddAttribute(HtmlTextWriterAttribute.Rel, "Stylesheet");
                writer.AddAttribute(HtmlTextWriterAttribute.Type, "text/css");
                writer.AddAttribute(HtmlTextWriterAttribute.Href, "?albummode=css");
                writer.RenderBeginTag(HtmlTextWriterTag.Link);
                writer.RenderEndTag(); // link
                writer.RenderBeginTag(HtmlTextWriterTag.Title);
                writer.WriteEncodedText(Title);
                writer.RenderEndTag(); // title
                writer.RenderBeginTag(HtmlTextWriterTag.Script);
                writer.Write(AlbumScript);
                writer.RenderEndTag(); // script
                writer.RenderEndTag(); // head
                writer.RenderBeginTag(HtmlTextWriterTag.Body);
            }

            if (PageModeTemplate != null) {
                Controls[0].RenderControl(writer);
            }
            else {
                EnsureNextPrevious();

                writer.AddAttribute(HtmlTextWriterAttribute.Border, "0");
                writer.RenderBeginTag(HtmlTextWriterTag.Table);
                writer.RenderBeginTag(HtmlTextWriterTag.Tr);
                writer.AddAttribute(HtmlTextWriterAttribute.Valign, "top");
                writer.RenderBeginTag(HtmlTextWriterTag.Td);
                writer.AddAttribute(HtmlTextWriterAttribute.Href, ParentFolder.Link, true);
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.AddAttribute(HtmlTextWriterAttribute.Src, ParentFolder.IconUrl, true);
                writer.AddAttribute(HtmlTextWriterAttribute.Alt, BackToFolderViewTooltip, true);
                writer.RenderBeginTag(HtmlTextWriterTag.Img);
                writer.RenderEndTag(); // img
                writer.RenderEndTag(); // a

                if (PreviousImage != null) {
                    writer.AddAttribute(HtmlTextWriterAttribute.Href, PreviousImage.Link, true);
                    writer.RenderBeginTag(HtmlTextWriterTag.A);
                    writer.AddAttribute(HtmlTextWriterAttribute.Src, PreviousImage.IconUrl, true);
                    writer.AddAttribute(HtmlTextWriterAttribute.Alt, PreviousImageTooltip, true);
                    writer.RenderBeginTag(HtmlTextWriterTag.Img);
                    writer.RenderEndTag(); // img
                    writer.RenderEndTag(); // a
                }
                else {
                    writer.Write("&nbsp;");
                }
                writer.WriteBreak();

                writer.AddAttribute(HtmlTextWriterAttribute.Href, "javascript:void(0)");
                writer.AddAttribute(HtmlTextWriterAttribute.Onclick,
                    @"photoAlbumDetails(""" +
                    (_isControl ? ClientID : String.Empty) +
                    @""")", true);
                writer.AddAttribute(HtmlTextWriterAttribute.Class, DetailsLinkCssClass);
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.Write(DetailsText);
                writer.RenderEndTag(); // a

                writer.AddAttribute(HtmlTextWriterAttribute.Border, "0");
                writer.AddAttribute(HtmlTextWriterAttribute.Id,
                    (_isControl ? ClientID : String.Empty) + "_details", true);
                writer.AddStyleAttribute(HtmlTextWriterStyle.Display, "none");
                writer.RenderBeginTag(HtmlTextWriterTag.Table);

                Dictionary<string, List<KeyValuePair<string, string>>> metadata = Image.MetaData;
                foreach (KeyValuePair<string, List<KeyValuePair<string, string>>> dir in metadata) {
                    writer.RenderBeginTag(HtmlTextWriterTag.Tr);
                    writer.AddAttribute(HtmlTextWriterAttribute.Valign, "top");
                    writer.AddAttribute(HtmlTextWriterAttribute.Class, MetaSectionHeadCssClass);
                    writer.AddAttribute(HtmlTextWriterAttribute.Colspan, "2");
                    writer.RenderBeginTag(HtmlTextWriterTag.Td);
                    writer.WriteEncodedText(dir.Key);
                    writer.RenderEndTag(); // td
                    writer.RenderEndTag(); // tr

                    foreach (KeyValuePair<string, string> data in dir.Value) {
                        writer.RenderBeginTag(HtmlTextWriterTag.Tr);
                        writer.AddAttribute(HtmlTextWriterAttribute.Valign, "top");
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, MetaNameCssClass);
                        writer.RenderBeginTag(HtmlTextWriterTag.Td);
                        writer.WriteEncodedText(data.Key);
                        writer.RenderEndTag(); // td
                        writer.AddAttribute(HtmlTextWriterAttribute.Valign, "top");
                        writer.AddAttribute(HtmlTextWriterAttribute.Class, MetaValueCssClass);
                        writer.RenderBeginTag(HtmlTextWriterTag.Td);
                        writer.WriteEncodedText(data.Value);
                        writer.RenderEndTag(); // td
                        writer.RenderEndTag(); // tr
                    }
                }

                writer.RenderEndTag(); // table
                writer.RenderEndTag(); // td

                writer.AddAttribute(HtmlTextWriterAttribute.Valign, "top");
                writer.RenderBeginTag(HtmlTextWriterTag.Td);

                writer.AddAttribute(HtmlTextWriterAttribute.Href, pictPath, true);
                writer.AddAttribute(HtmlTextWriterAttribute.Target, "_blank");
                writer.RenderBeginTag(HtmlTextWriterTag.A);
                writer.AddAttribute(HtmlTextWriterAttribute.Src, Image.PreviewUrl, true);
                writer.AddAttribute(HtmlTextWriterAttribute.Alt, DisplayFullResolutionTooltip, true);
                writer.RenderBeginTag(HtmlTextWriterTag.Img);
                writer.RenderEndTag(); // img
                writer.RenderEndTag(); // a

                writer.RenderEndTag(); // td

                writer.AddAttribute(HtmlTextWriterAttribute.Valign, "top");
                writer.RenderBeginTag(HtmlTextWriterTag.Td);

                if (NextImage != null) {
                    writer.AddAttribute(HtmlTextWriterAttribute.Href, NextImage.Link, true);
                    writer.RenderBeginTag(HtmlTextWriterTag.A);
                    writer.AddAttribute(HtmlTextWriterAttribute.Src, NextImage.IconUrl, true);
                    writer.AddAttribute(HtmlTextWriterAttribute.Alt, NextImageTooltip, true);
                    writer.RenderBeginTag(HtmlTextWriterTag.Img);
                    writer.RenderEndTag(); // img
                    writer.RenderEndTag(); // a
                }
                else {
                    writer.Write("&nbsp;");
                }

                writer.RenderEndTag(); // td
                writer.RenderEndTag(); // tr
                writer.RenderEndTag(); // table
            }

            if (_isControl) {
                if (!Page.IsCallback) {
                    writer.RenderEndTag(); // div
                }
            }
            else {
                writer.RenderEndTag(); // body
                writer.RenderEndTag(); // html
            }
        }

        /// <summary>
        /// Sends a 500 error to the client.
        /// </summary>
        /// <param name="msg">The error message.</param>
        void ReportError(string msg) {
            throw new HttpException(500, msg);
        }

        /// <summary>
        /// Parses the parameters from the querystring.
        /// </summary>
        void ParseParams() {
            ParseParams(_request.QueryString);
        }

        /// <summary>
        /// Parses the parameters.
        /// </summary>
        /// <param name="paramsCollection">The parameter collection to parse from.</param>
        void ParseParams(NameValueCollection paramsCollection) {
            string s;

            s = paramsCollection["albummode"];

            if (s != null) {
                try {
                    _mode = (AlbumHandlerMode)Enum.Parse(typeof(AlbumHandlerMode), s, true);
                }
                catch {
                }

                if (_mode == AlbumHandlerMode.Unknown) {
                    ReportError("invalid mode");
                }
            }
            else {
                _mode = AlbumHandlerMode.Folder;
            }

            s = paramsCollection["albumpath"];

            Path = s;
        }

        void IPostBackEventHandler.RaisePostBackEvent(string eventArgument) {
            Page.ClientScript.ValidateEvent(UniqueID, eventArgument);
            char command = eventArgument[0];
            string arg = eventArgument.Substring(1);
            switch (command) {
                case FolderCommand:
                    _mode = AlbumHandlerMode.Folder;
                    Path = arg;
                    break;
                case PageCommand:
                    _mode = AlbumHandlerMode.Page;
                    Path = arg;
                    break;
            }
        }

        private string _callbackEventArg;

        string ICallbackEventHandler.GetCallbackResult() {
            ((IPostBackEventHandler)this).RaisePostBackEvent(_callbackEventArg);
            ChildControlsCreated = false;
            using (StringWriter swriter = new StringWriter()) {
                using (HtmlTextWriter writer = new HtmlTextWriter(swriter)) {
                    EnsureChildControls();
                    RenderControl(writer);
                }
                return swriter.ToString();
            }
        }

        void ICallbackEventHandler.RaiseCallbackEvent(string eventArgument) {
            _callbackEventArg = eventArgument;
        }
    }
}
// -->