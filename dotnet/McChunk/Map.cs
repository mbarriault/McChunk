using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Drawing;

namespace WpfApplication1
{
    class Map : Grid
    {
        private static Point fromRegion(string regionFile)
        {
            string[] comps = System.IO.Path.GetFileNameWithoutExtension(regionFile).Split('.');
            Point pt = new Point(Convert.ToInt32(comps[1]), Convert.ToInt32(comps[2]));
            return pt;
        }
        public Map(string path)
        {
            this.ShowGridLines = true;
            string[] files = System.IO.Directory.GetFiles(path);
            Point[] offsets = new Point[files.Length];
            Point BL = new Point(0, 0);
            Point UR = new Point(0, 0);
            for (int i = 0; i < files.Length; i++)
            {
                offsets[i] = fromRegion(files[i]);
                if (offsets[i].X < BL.X)
                    BL.X = offsets[i].X;
                if (offsets[i].X > UR.X)
                    UR.X = offsets[i].X;
                if (offsets[i].Y < BL.Y)
                    BL.Y = offsets[i].Y;
                if (offsets[i].Y > UR.Y)
                    UR.Y = offsets[i].Y;
            }
            this.Width = (UR.X - BL.X + 1) * 512;
            this.Height = (UR.Y - BL.X + 1) * 512;

            for (int i = BL.X; i < UR.X+1; i++)
                this.ColumnDefinitions.Add(new ColumnDefinition());
            for (int j = BL.Y; j < UR.Y+1; j++)
                this.RowDefinitions.Add(new RowDefinition());

            for (int i = 0; i < files.Length; i++)
            {
                offsets[i].X -= BL.X;
                offsets[i].Y -= BL.Y;
                Region region = new Region(files[i], BL);
                Grid.SetRow(region, offsets[i].X);
                Grid.SetColumn(region, offsets[i].Y);
                this.Children.Add(region);
            }
        }
    }
}
