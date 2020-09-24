package be.openclinic.datacenter;
import java.awt.Color;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.LinkedList;
import javax.mail.MessagingException;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.data.time.Day;
import org.jfree.data.time.RegularTimePeriod;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;
import org.jfree.data.time.TimeSeriesDataItem;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.StatFunctions;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfPCell;
public class BedOccupancyGraph {
    /*
   USED TO CREATE A IMAGE OF GRAPH
    */
    public static String drawSimpleValueGraph(int serverId, String code, String sLanguage, String userid) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            TimeSeries series = new TimeSeries("data");
            conn = MedwanQuery.getInstance().getStatsConnection();
            ps = conn.prepareStatement("select * from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_CODETYPE='KPGS' and DC_DIAGNOSISVALUE_CODE=? and DC_DIAGNOSISVALUE_YEAR>? order by DC_DIAGNOSISVALUE_YEAR,DC_DIAGNOSISVALUE_MONTH");
            ps.setInt(1, serverId);
            ps.setString(2, code);
            ps.setInt(3, MedwanQuery.getInstance().getConfigInt("datacenterFirstGraphYear", 1900));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                series.addOrUpdate(new Day(ScreenHelper.parseDate("01/" + rs.getString("DC_DIAGNOSISVALUE_MONTH") + "/" + rs.getString("DC_DIAGNOSISVALUE_YEAR"))), Integer.parseInt(rs.getString("DC_DIAGNOSISVALUE_COUNT")));
            }
            rs.close();
            TimeSeriesCollection dataset = new TimeSeriesCollection(series);
            // create chart
            final JFreeChart chart = ChartFactory.createTimeSeriesChart(
                    ScreenHelper.getTranNoLink("datacenterserver", serverId + "", sLanguage) + "\n" + MedwanQuery.getInstance().getCodeTran("icd10code" + code, sLanguage), // chart title
                    ScreenHelper.getTranNoLink("web", "time", sLanguage), // domain axis label
                    "#", // range axis label
                    dataset, // data
                    false, // legend
                    false, // tooltips
                    false // urls
            );
            // customize chart
            chart.setAntiAlias(true);
            // round dots for all series
            XYPlot plot = chart.getXYPlot();
            plot.setBackgroundPaint(Color.WHITE);
            plot.setRangeGridlinePaint(Color.GRAY);
            plot.setDomainGridlinePaint(Color.GRAY);
            XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
            int dotSize = 4;
            renderer.setSeriesShape(0, new Ellipse2D.Double(dotSize / 2.0 * (-1), dotSize / 2.0 * (-1), dotSize, dotSize));
            renderer.setSeriesShapesVisible(1, false);
            renderer.setSeriesPaint(0, Color.BLACK);
            renderer.setSeriesPaint(1, Color.RED);
            plot.setRenderer(renderer);
            File file = new File(MedwanQuery.getInstance().getConfigString("DocumentsFolder") + "/" + userid + "." + serverId + "." + code + ".png");
            file.delete();
            ChartUtilities.saveChartAsPNG(file, chart, 640, 480);
            return file.getName();
        }
        catch (Exception e) {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException e2) {
                // TODO Auto-generated catch block
                e2.printStackTrace();
            }
            e.printStackTrace();
        }
        finally {
            try {
                conn.close();
            } catch (SQLException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return null;
    }
    /*
    METHOD TO USE
    Will create a Sorted List
    */
    public static List getListValueGraph(int serverId, String serviceuid, String sLanguage, String userid) {
        Connection conn = null;
        PreparedStatement ps = null;
        List lArray = new LinkedList();
        try {
            TimeSeries series = new TimeSeries("data");
            conn = MedwanQuery.getInstance().getStatsConnection();
            ps = conn.prepareStatement("select * from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=? and DC_BEDOCCUPANCYVALUE_SERVICEUID like ? order by DC_BEDOCCUPANCYVALUE_DATE");
            ps.setInt(1, serverId);
            ps.setString(2, serviceuid+";%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Date dDate = new java.util.Date(rs.getTimestamp("DC_BEDOCCUPANCYVALUE_DATE").getTime());
                Double iValue = Double.parseDouble(rs.getString("DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS"))*100/Double.parseDouble(rs.getString("DC_BEDOCCUPANCYVALUE_TOTALBEDS"));
                lArray.add(new Object[]{dDate, iValue});
            }
            rs.close();
        }
        catch (Exception e) {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException e2) {
                // TODO Auto-generated catch block
                e2.printStackTrace();
            }
            e.printStackTrace();
        }
        finally {
            try {
                conn.close();
            } catch (SQLException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return lArray;
    }
}
