using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Drawing;

namespace WpfApplication1
{
    class Region : Grid
    {
        public Point offset;
        public string path;
        public int x;
        public int z;
        public Region(string path, Point offset)
        {
            this.offset = offset;
            this.path = path;
            string[] comps = System.IO.Path.GetFileNameWithoutExtension(path).Split('.');
            x = Convert.ToInt32(comps[1]);
            z = Convert.ToInt32(comps[2]);

            this.Width = 512;
            this.Height = 512;
            for (int i = 0; i < 32; i++)
                this.ColumnDefinitions.Add(new ColumnDefinition());
            for (int j = 0; j < 32; j++)
                this.RowDefinitions.Add(new RowDefinition());

            for (int i = 0; i < 32; i++)
            {
                for (int j = 0; j < 32; j++)
                {
                    TextBlock txt = new TextBlock();
                    txt.Width = 16;
                    txt.Height = 16;
                    Int32 ij = new Int32();
                    ij = i + 32 * j;
                    txt.Text = ij.ToString();
                    Grid.SetRow(txt, i);
                    Grid.SetColumn(txt, j);
                    this.Children.Add(txt);
                }
            }
        }
    }
}
