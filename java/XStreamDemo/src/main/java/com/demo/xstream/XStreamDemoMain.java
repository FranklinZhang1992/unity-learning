package com.demo.xstream;

import com.demo.xstream.bean.Address;
import com.demo.xstream.bean.Person;
import com.demo.xstream.bean.Profile;
import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.xml.DomDriver;

public class XStreamDemoMain {

    public static void main(String[] args) {
        XStream xStream = new XStream(new DomDriver());
        xStream.processAnnotations(Person.class);
        xStream.autodetectAnnotations(true);

        xStream.alias("PERSON", Person.class);
        xStream.alias("PROFILE", Profile.class);
        xStream.alias("ADDRESS", Address.class);

        Person person = (Person) xStream.fromXML(getXML());
        String xml = xStream.toXML(person);
        System.out.println(xml);
    }

    private static String getXML() {
        return "<PERSON id=\"123\">\n" +
                "  <name>X-rapido</name>\n" +
                "  <age>22</age>\n" +
                "  <profile type=\"en\">\n" +
                "    <job type=\"技术\">软件工程师</job>\n" +
                "    <tel>13051594850</tel>\n" +
                "    <remark>备注说明</remark>\n" +
                "  </profile>\n" +
                "  <addlist>\n" +
                "    <ADDRESS>\n" +
                "      <add>郑州市经三路</add>\n" +
                "      <zipcode>450001</zipcode>\n" +
                "    </ADDRESS>\n" +
                "    <ADDRESS>\n" +
                "      <add>北京市海淀区</add>\n" +
                "      <zipcode>100000</zipcode>\n" +
                "    </ADDRESS>\n" +
                "  </addlist>\n" +
                "</PERSON>";
    }

}
