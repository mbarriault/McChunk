using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Forms;

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        string mapFilename;

        public void openRegion(object sender, RoutedEventArgs e)
        {
            FolderBrowserDialog dlg = new FolderBrowserDialog();
            DialogResult result = dlg.ShowDialog();
            dlg.RootFolder = System.Environment.SpecialFolder.ApplicationData;

            if (result == System.Windows.Forms.DialogResult.OK )
            {
                mapFilename = dlg.SelectedPath;
                openMap(mapFilename);
            }
        }

        private void openMap(string path)
        {
            ScrollViewer theScroll = new ScrollViewer();
            theScroll.HorizontalScrollBarVisibility = ScrollBarVisibility.Auto;
            theScroll.VerticalScrollBarVisibility = ScrollBarVisibility.Auto;
            theScroll.Content = new Map(path);
            this.Content = theScroll;
        }
    }
}
