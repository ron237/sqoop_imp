// ORM class for table 'null'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Thu Jun 18 15:49:54 CST 2020
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class QueryResult extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private String city_id;
  public String get_city_id() {
    return city_id;
  }
  public void set_city_id(String city_id) {
    this.city_id = city_id;
  }
  public QueryResult with_city_id(String city_id) {
    this.city_id = city_id;
    return this;
  }
  private String city;
  public String get_city() {
    return city;
  }
  public void set_city(String city) {
    this.city = city;
  }
  public QueryResult with_city(String city) {
    this.city = city;
    return this;
  }
  private String province_id;
  public String get_province_id() {
    return province_id;
  }
  public void set_province_id(String province_id) {
    this.province_id = province_id;
  }
  public QueryResult with_province_id(String province_id) {
    this.province_id = province_id;
    return this;
  }
  private String del_flg;
  public String get_del_flg() {
    return del_flg;
  }
  public void set_del_flg(String del_flg) {
    this.del_flg = del_flg;
  }
  public QueryResult with_del_flg(String del_flg) {
    this.del_flg = del_flg;
    return this;
  }
  private String creater_id;
  public String get_creater_id() {
    return creater_id;
  }
  public void set_creater_id(String creater_id) {
    this.creater_id = creater_id;
  }
  public QueryResult with_creater_id(String creater_id) {
    this.creater_id = creater_id;
    return this;
  }
  private String create_dt;
  public String get_create_dt() {
    return create_dt;
  }
  public void set_create_dt(String create_dt) {
    this.create_dt = create_dt;
  }
  public QueryResult with_create_dt(String create_dt) {
    this.create_dt = create_dt;
    return this;
  }
  private String updater_id;
  public String get_updater_id() {
    return updater_id;
  }
  public void set_updater_id(String updater_id) {
    this.updater_id = updater_id;
  }
  public QueryResult with_updater_id(String updater_id) {
    this.updater_id = updater_id;
    return this;
  }
  private String update_dt;
  public String get_update_dt() {
    return update_dt;
  }
  public void set_update_dt(String update_dt) {
    this.update_dt = update_dt;
  }
  public QueryResult with_update_dt(String update_dt) {
    this.update_dt = update_dt;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof QueryResult)) {
      return false;
    }
    QueryResult that = (QueryResult) o;
    boolean equal = true;
    equal = equal && (this.city_id == null ? that.city_id == null : this.city_id.equals(that.city_id));
    equal = equal && (this.city == null ? that.city == null : this.city.equals(that.city));
    equal = equal && (this.province_id == null ? that.province_id == null : this.province_id.equals(that.province_id));
    equal = equal && (this.del_flg == null ? that.del_flg == null : this.del_flg.equals(that.del_flg));
    equal = equal && (this.creater_id == null ? that.creater_id == null : this.creater_id.equals(that.creater_id));
    equal = equal && (this.create_dt == null ? that.create_dt == null : this.create_dt.equals(that.create_dt));
    equal = equal && (this.updater_id == null ? that.updater_id == null : this.updater_id.equals(that.updater_id));
    equal = equal && (this.update_dt == null ? that.update_dt == null : this.update_dt.equals(that.update_dt));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof QueryResult)) {
      return false;
    }
    QueryResult that = (QueryResult) o;
    boolean equal = true;
    equal = equal && (this.city_id == null ? that.city_id == null : this.city_id.equals(that.city_id));
    equal = equal && (this.city == null ? that.city == null : this.city.equals(that.city));
    equal = equal && (this.province_id == null ? that.province_id == null : this.province_id.equals(that.province_id));
    equal = equal && (this.del_flg == null ? that.del_flg == null : this.del_flg.equals(that.del_flg));
    equal = equal && (this.creater_id == null ? that.creater_id == null : this.creater_id.equals(that.creater_id));
    equal = equal && (this.create_dt == null ? that.create_dt == null : this.create_dt.equals(that.create_dt));
    equal = equal && (this.updater_id == null ? that.updater_id == null : this.updater_id.equals(that.updater_id));
    equal = equal && (this.update_dt == null ? that.update_dt == null : this.update_dt.equals(that.update_dt));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.city_id = JdbcWritableBridge.readString(1, __dbResults);
    this.city = JdbcWritableBridge.readString(2, __dbResults);
    this.province_id = JdbcWritableBridge.readString(3, __dbResults);
    this.del_flg = JdbcWritableBridge.readString(4, __dbResults);
    this.creater_id = JdbcWritableBridge.readString(5, __dbResults);
    this.create_dt = JdbcWritableBridge.readString(6, __dbResults);
    this.updater_id = JdbcWritableBridge.readString(7, __dbResults);
    this.update_dt = JdbcWritableBridge.readString(8, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.city_id = JdbcWritableBridge.readString(1, __dbResults);
    this.city = JdbcWritableBridge.readString(2, __dbResults);
    this.province_id = JdbcWritableBridge.readString(3, __dbResults);
    this.del_flg = JdbcWritableBridge.readString(4, __dbResults);
    this.creater_id = JdbcWritableBridge.readString(5, __dbResults);
    this.create_dt = JdbcWritableBridge.readString(6, __dbResults);
    this.updater_id = JdbcWritableBridge.readString(7, __dbResults);
    this.update_dt = JdbcWritableBridge.readString(8, __dbResults);
  }
  public void loadLargeObjects(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void loadLargeObjects0(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void write(PreparedStatement __dbStmt) throws SQLException {
    write(__dbStmt, 0);
  }

  public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeString(city_id, 1 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(city, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(province_id, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(del_flg, 4 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(creater_id, 5 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(create_dt, 6 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(updater_id, 7 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(update_dt, 8 + __off, 12, __dbStmt);
    return 8;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeString(city_id, 1 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(city, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(province_id, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(del_flg, 4 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(creater_id, 5 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(create_dt, 6 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(updater_id, 7 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(update_dt, 8 + __off, 12, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.city_id = null;
    } else {
    this.city_id = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.city = null;
    } else {
    this.city = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.province_id = null;
    } else {
    this.province_id = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.del_flg = null;
    } else {
    this.del_flg = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.creater_id = null;
    } else {
    this.creater_id = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.create_dt = null;
    } else {
    this.create_dt = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.updater_id = null;
    } else {
    this.updater_id = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.update_dt = null;
    } else {
    this.update_dt = Text.readString(__dataIn);
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.city_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, city_id);
    }
    if (null == this.city) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, city);
    }
    if (null == this.province_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, province_id);
    }
    if (null == this.del_flg) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, del_flg);
    }
    if (null == this.creater_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, creater_id);
    }
    if (null == this.create_dt) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, create_dt);
    }
    if (null == this.updater_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, updater_id);
    }
    if (null == this.update_dt) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, update_dt);
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.city_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, city_id);
    }
    if (null == this.city) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, city);
    }
    if (null == this.province_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, province_id);
    }
    if (null == this.del_flg) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, del_flg);
    }
    if (null == this.creater_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, creater_id);
    }
    if (null == this.create_dt) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, create_dt);
    }
    if (null == this.updater_id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, updater_id);
    }
    if (null == this.update_dt) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, update_dt);
    }
  }
  private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
  public String toString() {
    return toString(__outputDelimiters, true);
  }
  public String toString(DelimiterSet delimiters) {
    return toString(delimiters, true);
  }
  public String toString(boolean useRecordDelim) {
    return toString(__outputDelimiters, useRecordDelim);
  }
  public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
    StringBuilder __sb = new StringBuilder();
    char fieldDelim = delimiters.getFieldsTerminatedBy();
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(city_id==null?"\\N":city_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(city==null?"\\N":city, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(province_id==null?"\\N":province_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(del_flg==null?"\\N":del_flg, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(creater_id==null?"\\N":creater_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(create_dt==null?"\\N":create_dt, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(updater_id==null?"\\N":updater_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(update_dt==null?"\\N":update_dt, delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(city_id==null?"\\N":city_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(city==null?"\\N":city, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(province_id==null?"\\N":province_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(del_flg==null?"\\N":del_flg, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(creater_id==null?"\\N":creater_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(create_dt==null?"\\N":create_dt, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(updater_id==null?"\\N":updater_id, delimiters));
    __sb.append(fieldDelim);
    // special case for strings hive, droppingdelimiters \n,\r,\01 from strings
    __sb.append(FieldFormatter.hiveStringDropDelims(update_dt==null?"\\N":update_dt, delimiters));
  }
  private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
  private RecordParser __parser;
  public void parse(Text __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharSequence __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(byte [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(char [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(ByteBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  private void __loadFromFields(List<String> fields) {
    Iterator<String> __it = fields.listIterator();
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.city_id = null; } else {
      this.city_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.city = null; } else {
      this.city = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.province_id = null; } else {
      this.province_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.del_flg = null; } else {
      this.del_flg = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.creater_id = null; } else {
      this.creater_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.create_dt = null; } else {
      this.create_dt = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.updater_id = null; } else {
      this.updater_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.update_dt = null; } else {
      this.update_dt = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.city_id = null; } else {
      this.city_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.city = null; } else {
      this.city = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.province_id = null; } else {
      this.province_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.del_flg = null; } else {
      this.del_flg = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.creater_id = null; } else {
      this.creater_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.create_dt = null; } else {
      this.create_dt = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.updater_id = null; } else {
      this.updater_id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.update_dt = null; } else {
      this.update_dt = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    QueryResult o = (QueryResult) super.clone();
    return o;
  }

  public void clone0(QueryResult o) throws CloneNotSupportedException {
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("city_id", this.city_id);
    __sqoop$field_map.put("city", this.city);
    __sqoop$field_map.put("province_id", this.province_id);
    __sqoop$field_map.put("del_flg", this.del_flg);
    __sqoop$field_map.put("creater_id", this.creater_id);
    __sqoop$field_map.put("create_dt", this.create_dt);
    __sqoop$field_map.put("updater_id", this.updater_id);
    __sqoop$field_map.put("update_dt", this.update_dt);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("city_id", this.city_id);
    __sqoop$field_map.put("city", this.city);
    __sqoop$field_map.put("province_id", this.province_id);
    __sqoop$field_map.put("del_flg", this.del_flg);
    __sqoop$field_map.put("creater_id", this.creater_id);
    __sqoop$field_map.put("create_dt", this.create_dt);
    __sqoop$field_map.put("updater_id", this.updater_id);
    __sqoop$field_map.put("update_dt", this.update_dt);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("city_id".equals(__fieldName)) {
      this.city_id = (String) __fieldVal;
    }
    else    if ("city".equals(__fieldName)) {
      this.city = (String) __fieldVal;
    }
    else    if ("province_id".equals(__fieldName)) {
      this.province_id = (String) __fieldVal;
    }
    else    if ("del_flg".equals(__fieldName)) {
      this.del_flg = (String) __fieldVal;
    }
    else    if ("creater_id".equals(__fieldName)) {
      this.creater_id = (String) __fieldVal;
    }
    else    if ("create_dt".equals(__fieldName)) {
      this.create_dt = (String) __fieldVal;
    }
    else    if ("updater_id".equals(__fieldName)) {
      this.updater_id = (String) __fieldVal;
    }
    else    if ("update_dt".equals(__fieldName)) {
      this.update_dt = (String) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("city_id".equals(__fieldName)) {
      this.city_id = (String) __fieldVal;
      return true;
    }
    else    if ("city".equals(__fieldName)) {
      this.city = (String) __fieldVal;
      return true;
    }
    else    if ("province_id".equals(__fieldName)) {
      this.province_id = (String) __fieldVal;
      return true;
    }
    else    if ("del_flg".equals(__fieldName)) {
      this.del_flg = (String) __fieldVal;
      return true;
    }
    else    if ("creater_id".equals(__fieldName)) {
      this.creater_id = (String) __fieldVal;
      return true;
    }
    else    if ("create_dt".equals(__fieldName)) {
      this.create_dt = (String) __fieldVal;
      return true;
    }
    else    if ("updater_id".equals(__fieldName)) {
      this.updater_id = (String) __fieldVal;
      return true;
    }
    else    if ("update_dt".equals(__fieldName)) {
      this.update_dt = (String) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
