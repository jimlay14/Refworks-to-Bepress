<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--Declaration of Stylesheet-->
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>


    <!-- a transformation for Refworks XML output into Digital Commons -->
    <!-- @authors Stephen X. Flynn, Catalina Oyler, and Marsha Miles; adapted by Jacob Imlay-->

    <!-- Match the named "refworks" template to the refworks xml file. Splits each reference into its own XML file -->
    <xsl:template match="refworks">
        <!-- match "refworks" the root of the xml-->

        <xsl:variable name="filename" select="concat('batchrefBP/', '/digital_commons_batch_.xml')"/>

        <!-- declares the dublin core file for this reference as the variable "filename," within the folder specified -->
        <xsl:variable name="contents" select="concat('batchrefBP/', '/contents')"/>
        <!-- declares the "contents" variable as a file to also place in the count folder -->

        <xsl:result-document href="{$filename}">
            <documents xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:noNamespaceSchemaLocation="http://www.bepress.com/document-import.xsd">
                <xsl:for-each select="reference">
                    <xsl:call-template name="refworks"/>
                </xsl:for-each>
            </documents>
        </xsl:result-document>
    </xsl:template>
    <!-- end of the matching template, which makes the files and calls the "refworks" template-->


    <!-- The refworks template, which formats references to plain text ready to import into Digital Commons -->

    <!-- Data that needs to be checked during batch revision:
            1. Publication Date (month)
            2. Abstract (search for available one) 
            3. Full text url 
            4. Document Type (may not be an article) 
            5. Department
            6. DOI link (if not included)
            7. Worldcat link
            8. Provider Link
            9. Source full text (if DOI not included) -->

    <xsl:template name="refworks" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="http://www.bepress.com/document-import.xsd">
        <!-- Variables removes the special characters used instead of quotation marks, and sets the title, publisher, and journal so they can be called in correct fields and as part of the citation -->
        <xsl:variable name="squote">'</xsl:variable>
        <!-- variable for small quotation marks -->
        <xsl:variable name="dquote">"</xsl:variable>
        <!-- variable for double quotation marks -->
        <xsl:variable name="amper">&amp;</xsl:variable>
        <!-- variable for & (ampersand) -->
        <xsl:variable name="Title"
            select="replace(replace(replace(t1, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;amp;', $amper)"/>
        <!-- formats title to remove xml characters -->
        <xsl:variable name="Publisher"
            select="replace(replace(replace(pb, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;amp;', $amper)"/>
        <!-- format publisher to remove xml characters -->
        <xsl:variable name="Journal"
            select="replace(replace(replace(jf, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;amp;', $amper)"/>
        <!-- format journal to remove xml characters -->

        <document>
            <!-- begin the document declaration -->

            <!-- Title field; packages title with first letters capitalized and
             as an xml element with a "qualifier" attribute -->
            <title>
                <!-- Calls template to translate into proper case -->
                <xsl:call-template name="TitleCase">
                    <xsl:with-param name="text"
                        select="translate(normalize-space($Title), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                    />
                </xsl:call-template>
            </title>

            <!-- Date field -->
            <publication-date>
                <!-- package as a date element with the qualifier attribute "issued" -->
                <xsl:value-of select="normalize-space(yr)"/>
                <!-- remove leading and trailing white space -->
                <!-- Attempts to write date as YYYY-MM when that information is present; uses a string builder format -->
                <xsl:choose>
                    <xsl:when test="fd">
                        <xsl:variable name="month">
                            <xsl:choose>
                                <xsl:when test="contains(fd,'/')">
                                    <xsl:value-of select="substring-before(fd,'/')"/>
                                </xsl:when>
                                <xsl:when test="contains(fd,';')">
                                    <xsl:value-of select="substring-before(fd,';')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="fd"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($month,'20')">
                                <xsl:text>-01</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'19')">
                                <xsl:text>-01</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'DEC')">
                                <xsl:text>-12</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Dec')">
                                <xsl:text>-12</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'dec')">
                                <xsl:text>-12</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='12'">
                                <xsl:text>-12</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'JAN')">
                                <xsl:text>-01</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Jan')">
                                <xsl:text>-01</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'jan')">
                                <xsl:text>-01</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='1'">
                                <xsl:text>-01</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'FEB')">
                                <xsl:text>-02</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Feb')">
                                <xsl:text>-02</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'feb')">
                                <xsl:text>-02</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='2'">
                                <xsl:text>-02</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'MAR')">
                                <xsl:text>-03</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Mar')">
                                <xsl:text>-03</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'mar')">
                                <xsl:text>-03</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='3'">
                                <xsl:text>-03</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'APR')">
                                <xsl:text>-04</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Apr')">
                                <xsl:text>-04</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'apr')">
                                <xsl:text>-04</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='4'">
                                <xsl:text>-04</xsl:text>
                            </xsl:when>


                            <xsl:when test="contains($month,'MAY')">
                                <xsl:text>-05</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'May')">
                                <xsl:text>-05</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'may')">
                                <xsl:text>-05</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='5'">
                                <xsl:text>-05</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'JUN')">
                                <xsl:text>-06</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Jun')">
                                <xsl:text>-06</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'jun')">
                                <xsl:text>-06</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='6'">
                                <xsl:text>-06</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'JUL')">
                                <xsl:text>-07</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Jul')">
                                <xsl:text>-07</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'jul')">
                                <xsl:text>-07</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='7'">
                                <xsl:text>-07</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'AUG')">
                                <xsl:text>-08</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Aug')">
                                <xsl:text>-08</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'aug')">
                                <xsl:text>-08</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='8'">
                                <xsl:text>-08</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'SEP')">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Sep')">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'sep')">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='9'">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'OCT')">
                                <xsl:text>-10</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Oct')">
                                <xsl:text>-10</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'oct')">
                                <xsl:text>-10</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='10'">
                                <xsl:text>-10</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'NOV')">
                                <xsl:text>-11</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Nov')">
                                <xsl:text>-11</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'nov')">
                                <xsl:text>-11</xsl:text>
                            </xsl:when>
                            <xsl:when test="$month='11'">
                                <xsl:text>-11</xsl:text>
                            </xsl:when>

                            <xsl:when test="contains($month,'WIN')">
                                <xsl:text>-12</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Win')">
                                <xsl:text>-12</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Winter')">
                                <xsl:text>-12</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Spring')">
                                <xsl:text>-03</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'SPR')">
                                <xsl:text>-03</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Spr')">
                                <xsl:text>-03</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Summer')">
                                <xsl:text>-06</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'SUM')">
                                <xsl:text>-06</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Sum')">
                                <xsl:text>-06</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'FAL')">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Fal')">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Fall')">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($month,'Autumn')">
                                <xsl:text>-09</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>-</xsl:text>
                                <xsl:apply-templates select="$month"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>-01</xsl:text>
                        <!-- If no month is available, assume December and edit later -->
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>-01</xsl:text>
                <!-- Date is required for formatting; edit later -->
            </publication-date>

            <!-- Author field ^^^-->
            <authors>
                <xsl:for-each select="a1">
                    <!-- For each author -->
                    <!-- Make author a case corrected variable for institution and email data -->
                    <xsl:variable name="author">
                        <xsl:choose>
                            <!-- Adds a space after the comma that seperates first and last names -->
                            <xsl:when test="contains(.,',')">
                                <xsl:variable name="last">
                                    <xsl:choose>
                                        <xsl:when test="contains(.,'Mc')">
                                            <xsl:variable name="post"
                                                select="substring-before(substring-after(.,'Mc'),',')"/>
                                            <xsl:text>Mc</xsl:text>
                                            <xsl:call-template name="TitleCase">
                                                <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                > </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="not(contains(.,'-'))">
                                            <xsl:call-template name="TitleCase">
                                                <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                > </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="substring-before(.,',')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="first">
                                    <xsl:call-template name="TitleCase">
                                        <xsl:with-param name="text"
                                            select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        > </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:value-of select="concat($last,', ',$first)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <author xsi:type="individual">
                        <email>
                            <xsl:choose>
                                <xsl:when test="contains($author,'Hogan, C')">
                                    <xsl:text>chogan@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Brown, G')">
                                    <xsl:text>gkbrown@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Adam, J')">
                                    <xsl:text>jadam@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Allen, R')">
                                    <xsl:text>rallen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Anderson-Connolly, R')">
                                    <xsl:text>raconnolly@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Andresen, D')">
                                    <xsl:text>dandresen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Austin, G')">
                                    <xsl:text>ggaustin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Barkin, G')">
                                    <xsl:text>barkin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Barry, W')">
                                    <xsl:text>bbarry@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bartanen, K')">
                                    <xsl:text>acadvp@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bates, B')">
                                    <xsl:text>bates@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beardsley, W')">
                                    <xsl:text>wbeardsley@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beck, T')">
                                    <xsl:text>tbeck@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beezer, R')">
                                    <xsl:text>beezer@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Benard, E')">
                                    <xsl:text>ebenard@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Benveniste, M')">
                                    <xsl:text>mbenveniste@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Berg, L')">
                                    <xsl:text>lberg@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bernhard, J')">
                                    <xsl:text>jbernhard@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beyer, T')">
                                    <xsl:text>tbeyer@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Billings, B')">
                                    <xsl:text>bbillings@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Block, G')">
                                    <xsl:text>block@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bodine, S')">
                                    <xsl:text>sbodine@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Boisvert, L')">
                                    <xsl:text>lboisvert@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bowen, S')">
                                    <xsl:text>sbowen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Boyles, R')">
                                    <xsl:text>bboyles@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Breitenbach, W')">
                                    <xsl:text>wbreitenbach@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bristow, N')">
                                    <xsl:text>nbristow@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Brody, N')">
                                    <xsl:text>nbrody@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Buescher, D')">
                                    <xsl:text>dbuescher@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Burgard, D')">
                                    <xsl:text>dburgard@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Burnett, R')">
                                    <xsl:text>rburnett@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Burns, N')">
                                    <xsl:text>nburns@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Butcher, A')">
                                    <xsl:text>butcher@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Cannon, D')">
                                    <xsl:text>dcannon@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Carotenuto, G')">
                                    <xsl:text>gcarotenuto@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Christensen, C')">
                                    <xsl:text>cchristensen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Christie, T')">
                                    <xsl:text>tchristie@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Christoph, J')">
                                    <xsl:text>jchristoph@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Claire, L')">
                                    <xsl:text>lclaire@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Clark, C')">
                                    <xsl:text>cynthiaclark@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Clark, K')">
                                    <xsl:text>kclark@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Colbert-White, E')">
                                    <xsl:text>ecolbertwhite@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Colosimo, J')">
                                    <xsl:text>jdcolosimo@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Conner, B')">
                                    <xsl:text>bconner@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Crane, J')">
                                    <xsl:text>jcrane@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Curley, M')">
                                    <xsl:text>curley@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'DeHart, M')">
                                    <xsl:text>mdehart@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Delos, M')">
                                    <xsl:text>mdelos@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Demarais, A')">
                                    <xsl:text>ademarais@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Demotts, R')">
                                    <xsl:text>rdemotts@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Despres, D')">
                                    <xsl:text>ddespres@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Dillman, B')">
                                    <xsl:text>bdillman@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Dove, W')">
                                    <xsl:text>wdove@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Doyle, S')">
                                    <xsl:text>sdoyle@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Edwards, H')">
                                    <xsl:text>hredwards@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Elliott, G')">
                                    <xsl:text>gelliott@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Elliott, J')">
                                    <xsl:text>jkelliott@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Erickson, K')">
                                    <xsl:text>klerickson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Erving, G')">
                                    <xsl:text>gerving@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Evans, Ja')">
                                    <xsl:text>jcevans@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ferrari, L')">
                                    <xsl:text>lferrari@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fields, K')">
                                    <xsl:text>kfields@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fisher, A')">
                                    <xsl:text>afisher@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Folsom, G')">
                                    <xsl:text>gfolsom@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fox-Dobbs, K')">
                                    <xsl:text>kena@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Freeman, Sa')">
                                    <xsl:text>sfreeman@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fry, P')">
                                    <xsl:text>pfry@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Galvan, M')">
                                    <xsl:text>mgalvan@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gardner, A')">
                                    <xsl:text>gardner@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Garratt, R')">
                                    <xsl:text>garratt@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gast, B')">
                                    <xsl:text>bgast@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gibson, C')">
                                    <xsl:text>cgibson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Glover, D')">
                                    <xsl:text>dglover@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Goldstein, B')">
                                    <xsl:text>goldstein@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gordon, D')">
                                    <xsl:text>dgordon@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Grinstead, J')">
                                    <xsl:text>jgrinstead@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Grunberg, L')">
                                    <xsl:text>grunberg@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gunderson, C')">
                                    <xsl:text>chgunderson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gurel-Atay, E')">
                                    <xsl:text>egurelatay@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hackett, A')">
                                    <xsl:text>ahackett@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hale, C')">
                                    <xsl:text>hale@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hale, A')">
                                    <xsl:text>ajtracy@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Haltom, W')">
                                    <xsl:text>haltom@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hamel, F')">
                                    <xsl:text>fhamel@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hands, D')">
                                    <xsl:text>hands@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hannaford, S')">
                                    <xsl:text>shannaford@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hanson, J')">
                                    <xsl:text>hanson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hanson, D')">
                                    <xsl:text>dhanson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Harpring, M')">
                                    <xsl:text>mharpring@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Harris, P')">
                                    <xsl:text>pharris@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hastings, J')">
                                    <xsl:text>jhastings@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Heavin, S')">
                                    <xsl:text>sheavin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hodum, P')">
                                    <xsl:text>phodum@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Holland, S')">
                                    <xsl:text>sholland@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hommel, C')">
                                    <xsl:text>hommel@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hong, Z')">
                                    <xsl:text>zhong@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hooper, Ken')">
                                    <xsl:text>hooper@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Houston, R')">
                                    <xsl:text>rhouston@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Howard, P')">
                                    <xsl:text>phoward@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hulbert, D')">
                                    <xsl:text>dhulbert@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hull, D')">
                                    <xsl:text>dhull@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hutchinson, R')">
                                    <xsl:text>rhutchinson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Imbrigotta, K')">
                                    <xsl:text>kimbrigotta@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ingalls, M')">
                                    <xsl:text>mingalls@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Irvin, D')">
                                    <xsl:text>dirvin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Isaacson, S')">
                                    <xsl:text>sisaacson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jackson, M')">
                                    <xsl:text>martinj@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jacobson, Rob')">
                                    <xsl:text>rjacobson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'James, An')">
                                    <xsl:text>abjames@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jasinski, J')">
                                    <xsl:text>jjasinski@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, K')">
                                    <xsl:text>kristinjohnson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, Mi')">
                                    <xsl:text>mjohnson2@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, L')">
                                    <xsl:text>ljohnson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, G')">
                                    <xsl:text>gregoryjohnson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jones, A')">
                                    <xsl:text>allenjones@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Joshi, P')">
                                    <xsl:text>pjoshi@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kaminsky, T')">
                                    <xsl:text>tkaminsky@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kay, J')">
                                    <xsl:text>jkay@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Keene, D')">
                                    <xsl:text>dkeene@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kelley, D')">
                                    <xsl:text>dkelley@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kessel, A')">
                                    <xsl:text>akessel@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kim, Ju')">
                                    <xsl:text>jkim@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'King, J')">
                                    <xsl:text>jking@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kirchner, G')">
                                    <xsl:text>kirchner@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kirkpatrick, B')">
                                    <xsl:text>kirkpatrick@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Knoop, T')">
                                    <xsl:text>tknoop@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Koelling, V')">
                                    <xsl:text>vkoelling@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kontogeorgopoulos, N')">
                                    <xsl:text>konto@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kotsis, K')">
                                    <xsl:text>kkotsis@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kowalski, C')">
                                    <xsl:text>ckowalski@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Krause, A')">
                                    <xsl:text>ajkrause@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Krueger, P')">
                                    <xsl:text>krueger@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kukreja, S')">
                                    <xsl:text>kukreja@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kupinse, W')">
                                    <xsl:text>wkupinse@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lago-Grana, J')">
                                    <xsl:text>jlago@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lamb, Ma')">
                                    <xsl:text>mrlamb@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Latimer, D')">
                                    <xsl:text>dlatimer@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lear, J')">
                                    <xsl:text>lear@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lehmann, K')">
                                    <xsl:text>klehmann@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Leuchtenberger, J')">
                                    <xsl:text>jleuchtenberger@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lewin, B')">
                                    <xsl:text>blewin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Linauts, M')">
                                    <xsl:text>mlinauts@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Livingston, G')">
                                    <xsl:text>glivingston@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Livingston, L')">
                                    <xsl:text>llivingston@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Loeb, P')">
                                    <xsl:text>loeb@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Looper, J')">
                                    <xsl:text>jlooper@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ludden, M')">
                                    <xsl:text>mludden@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ly, P')">
                                    <xsl:text>ply@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Macbain, T')">
                                    <xsl:text>tamacbain@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Madlung, A')">
                                    <xsl:text>amadlung@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mahato, M')">
                                    <xsl:text>mmahato@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mann, B')">
                                    <xsl:text>mann@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Marcavage, J')">
                                    <xsl:text>jmarcavage@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Martin, Mark')">
                                    <xsl:text>momartin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Massey, M')">
                                    <xsl:text>mmassey@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Matthews, Je')">
                                    <xsl:text>jmatthews@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Matthews, R')">
                                    <xsl:text>matthews@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McCall, G')">
                                    <xsl:text>gmccall@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McCullough, J')">
                                    <xsl:text>mccullough@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McMillian, D')">
                                    <xsl:text>dmcmillian@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McNulty-Wooster, P')">
                                    <xsl:text>pwooster@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Melchior, A')">
                                    <xsl:text>amelchior@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mifflin, A')">
                                    <xsl:text>amifflin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Milam, G')">
                                    <xsl:text>gmilam@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Monaco, A')">
                                    <xsl:text>amonaco@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Moore, S')">
                                    <xsl:text>smoore@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Moore, Da')">
                                    <xsl:text>dmoore2@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Morris, G')">
                                    <xsl:text>gmorris@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Morse, L')">
                                    <xsl:text>lmorse@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mulhausen, N')">
                                    <xsl:text>nmulhausen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Murphy, K')">
                                    <xsl:text>kmurphy@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Murphy, H')">
                                    <xsl:text>hamurphy@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Myhre, C')">
                                    <xsl:text>cmyhre@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nealey-Moore, J')">
                                    <xsl:text>jnmoore@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nelson, Jen')">
                                    <xsl:text>jnelson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Neshyba, S')">
                                    <xsl:text>nesh@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nowak, M')">
                                    <xsl:text>mnowak@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nunn, E')">
                                    <xsl:text>enunn@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Odegard, A')">
                                    <xsl:text>aodegard@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Olney, M')">
                                    <xsl:text>rolney@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'eil, P')">
                                    <xsl:text>poneil@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Orechia, M')">
                                    <xsl:text>morechia@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Orlin, E')">
                                    <xsl:text>eorlin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Orloff, H')">
                                    <xsl:text>horloff@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ostrom, H')">
                                    <xsl:text>ostrom@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Owen, A')">
                                    <xsl:text>sowen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Owen, Sus')">
                                    <xsl:text>sowen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Padula, D')">
                                    <xsl:text>dpadula@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Paradise, A')">
                                    <xsl:text>paradise@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Paterson, E')">
                                    <xsl:text>epaterson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Peine, E')">
                                    <xsl:text>epeine@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Perret, A')">
                                    <xsl:text>aperret@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Perret, S')">
                                    <xsl:text>sperret@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Perry, Lo Sun')">
                                    <xsl:text>perry@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Pickard, M')">
                                    <xsl:text>pickard@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Preszler, J')">
                                    <xsl:text>jpreszler@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Proehl, G')">
                                    <xsl:text>gproehl@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Pugh, M')">
                                    <xsl:text>mpugh@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Putnam, A')">
                                    <xsl:text>aputnam@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rafanelli, P')">
                                    <xsl:text>prafanelli@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ramakrishnan, S')">
                                    <xsl:text>sramakrishnan@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ramee, J')">
                                    <xsl:text>jaramee@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ramirez Dueker, A')">
                                    <xsl:text>ardueker@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Reich, J')">
                                    <xsl:text>breich@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Reinitz, M')">
                                    <xsl:text>mreinitz@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Requiro, D')">
                                    <xsl:text>drequiro@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rex, A')">
                                    <xsl:text>rex@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rice, D')">
                                    <xsl:text>drice@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Richards, B')">
                                    <xsl:text>brichards@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Richman, E')">
                                    <xsl:text>erichman@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rickoll, W')">
                                    <xsl:text>rickoll@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rink, S')">
                                    <xsl:text>srink@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rocchi, M')">
                                    <xsl:text>rocchi@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rodgers, S')">
                                    <xsl:text>rodgers@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rogers, B')">
                                    <xsl:text>bmrogers@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Root, J')">
                                    <xsl:text>jroot@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ross, Joel')">
                                    <xsl:text>jross@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ryken, A')">
                                    <xsl:text>aryken@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sackman, D')">
                                    <xsl:text>dsackman@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sampen, M')">
                                    <xsl:text>msampen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sandler, F')">
                                    <xsl:text>fsandler@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Saucedo, L')">
                                    <xsl:text>lsaucedo@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Scharrer, E')">
                                    <xsl:text>escharrer@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Schauble, R')">
                                    <xsl:text>music.admission@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Schermer, S')">
                                    <xsl:text>sschermer@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Schultz, R')">
                                    <xsl:text>rschultz@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Scott, Jud')">
                                    <xsl:text>jscott@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Shapiro, S')">
                                    <xsl:text>sshapiro@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Share, D')">
                                    <xsl:text>share@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sherman, D')">
                                    <xsl:text>dsherman@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Simms, R')">
                                    <xsl:text>rsimms@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Siu, O')">
                                    <xsl:text>osiu@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, J')">
                                    <xsl:text>jksmith@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, D')">
                                    <xsl:text>dfsmith@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, K')">
                                    <xsl:text>kasmith2@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, Adam')">
                                    <xsl:text>adamasmith@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, Bryan')">
                                    <xsl:text>bryans@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smithers, S')">
                                    <xsl:text>smithers@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sousa, D')">
                                    <xsl:text>sousa@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Spivey, A')">
                                    <xsl:text>aspivey@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Spivey, M')">
                                    <xsl:text>mspivey@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Stambuk, T')">
                                    <xsl:text>tstambuk@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Stirling, K')">
                                    <xsl:text>stirling@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Stockdale, J')">
                                    <xsl:text>jstockdale@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Strausberg, L')">
                                    <xsl:text>lstrausberg@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Styer, S')">
                                    <xsl:text>sstyer@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sultemeier, D')">
                                    <xsl:text>dsultemeier@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Swinth, Y')">
                                    <xsl:text>yswinth@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tamashiro, J')">
                                    <xsl:text>jtamashiro@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tanaka, T')">
                                    <xsl:text>ttanaka@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tanta, K')">
                                    <xsl:text>ktanta@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tepper, J')">
                                    <xsl:text>jtepper@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Thomas, R')">
                                    <xsl:text>president@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tiehen, J')">
                                    <xsl:text>jtiehen@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tinsley, D')">
                                    <xsl:text>tinsley@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Toews, C')">
                                    <xsl:text>ctoews@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tomlin, G')">
                                    <xsl:text>tomlin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Townson, K')">
                                    <xsl:text>ktownson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tromly, B')">
                                    <xsl:text>btromly@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tubert, A')">
                                    <xsl:text>atubert@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tullis, A')">
                                    <xsl:text>atullis@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Udbye, A')">
                                    <xsl:text>audbye@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Utrata, J')">
                                    <xsl:text>jutrata@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Valentine, M')">
                                    <xsl:text>mvalentine@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Van Parys, D')">
                                    <xsl:text>dvanparys@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Vélez-Quiñones, Harry')">
                                    <xsl:text>velez@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Walls, K')">
                                    <xsl:text>kwalls@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Walston, V')">
                                    <xsl:text>vwalston@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ward, K')">
                                    <xsl:text>kward@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warning, M')">
                                    <xsl:text>mwarning@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warnke Flygare, K')">
                                    <xsl:text>kflygare@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warren, B')">
                                    <xsl:text>blwarren@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warren, Suz')">
                                    <xsl:text>sewarren@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Weinberger, S')">
                                    <xsl:text>sweinberger@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Weiss, S')">
                                    <xsl:text>sweiss@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Weisz, C')">
                                    <xsl:text>cweisz@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wesley, J')">
                                    <xsl:text>jwesley@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wiese, N')">
                                    <xsl:text>nwiese@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilbur, K')">
                                    <xsl:text>kwilbur@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Williams, D')">
                                    <xsl:text>dwilliams@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Williams, L')">
                                    <xsl:text>lwilliams@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Williams, M')">
                                    <xsl:text>mswilliams@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilson, Jennifer')">
                                    <xsl:text>jneighbors@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilson, P')">
                                    <xsl:text>pwilson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilson, A')">
                                    <xsl:text>awilson@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wimberger, P')">
                                    <xsl:text>pwimberger@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Winkler, F')">
                                    <xsl:text>fwinkler@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wolf, B')">
                                    <xsl:text>bwolf@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wood, L')">
                                    <xsl:text>lwood@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Woodward, J')">
                                    <xsl:text>woodward@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Worland, R')">
                                    <xsl:text>worland@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Zopfi, S')">
                                    <xsl:text>szopfi@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Robbeloth, H')">
                                    <xsl:text>hrobbeloth@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Carlin, J')">
                                    <xsl:text>jcarlin@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ricigliano, L')">
                                    <xsl:text>ricigliano@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Peters, E')">
                                    <xsl:text>epeters@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kueter, A')">
                                    <xsl:text>akueter@pugetsound.edu</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Firman, P')">
                                    <xsl:text>akueter@pugetsound.edu</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </email>
                        <institution>
                            <xsl:choose>
                                <xsl:when test="contains($author,'Hogan, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Balaam, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Peters, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ricigliano, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Brown, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Adam, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Allen, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Anderson-Connolly, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Andresen, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Austin, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Barkin, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Barry, W')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bartanen, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bates, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beardsley, W')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beck, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beezer, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Benard, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Benveniste, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Berg, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bernhard, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Beyer, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Billings, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Block, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bodine, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Boisvert, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bowen, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Boyles, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Breitenbach, W')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Bristow, N')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Brody, N')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Buescher, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Burgard, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Burnett, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Burnett, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Burns, N')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Butcher, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Cannon, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Carlin, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Carotenuto, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Christensen, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Christie, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Christoph, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Claire, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Clark, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Clark, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Colbert-White, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Colosimo, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Conner, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Crane, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Curley, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'DeHart, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Delos, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Demarais, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Demotts, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Despres, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Dillman, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Dove, W')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Doyle, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Edwards, H')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Elliott, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Elliott, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Erickson, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Erving, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Evans, Ja')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ferrari, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fields, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fisher, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Folsom, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fox-Dobbs, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Freeman, Sa')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Fry, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Galvan, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gardner, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Garratt, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gast, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gibson, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Glover, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Goldstein, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gordon, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Grinstead, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Grunberg, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gunderson, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Gurel-Atay, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hackett, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hale, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hale, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Haltom, W')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hamel, F')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hands, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hannaford, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hanson, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hanson, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Harpring, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Harris, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hastings, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Heavin, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hodum, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Holland, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hommel, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hong, Z')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hooper, Ken')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Houston, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Howard, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hoyt, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hulbert, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hull, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Hutchinson, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Imbrigotta, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ingalls, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Irvin, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Isaacson, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jackson, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jacobson, Rob')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'James, An')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jasinski, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, Mi')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Johnson, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Jones, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Joshi, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kaminsky, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kay, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Keene, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kelley, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kessel, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kim, Ju')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'King, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kirchner, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kirkpatrick, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Knoop, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Koelling, Va')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kontogeorgopoulos, N')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kotsis, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kowalski, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Krause, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Krueger, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kukreja, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Kupinse, W')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lago-Grana, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lamb, Ma')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Latimer, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lear, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lehmann, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Leuchtenberger, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lewin, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Linauts, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Livingston, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Livingston, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Loeb, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Looper, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ludden, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ly, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Macbain, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Madlung, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mahato, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mann, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Marcavage, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Martin, Mark')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Massey, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Matthews, Je')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Matthews, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McCall, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McCullough, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McMillian, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'McNulty-Wooster, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Melchior, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mifflin, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Milam, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Monaco, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Moore, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Moore, Da')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Morris, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Morse, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Mulhausen, N')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Murphy, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Murphy, H')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Myhre, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nealey-Moore, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nelson, Jen')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Neshyba, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nowak, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Nunn, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Odegard, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Olney, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'eil, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Orechia, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Orlin, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Orloff, H')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ostrom, H')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Owen, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Owen, Sus')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Padula, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Paradise, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Paterson, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Peine, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Perret, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Perret, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Perry, Lo Sun')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Pickard, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Preszler, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Proehl, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Pugh, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Putnam, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rafanelli, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ramakrishnan, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ramee, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ramirez Dueker, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Reich, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Reinitz, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Requiro, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rex, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rice, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Richards, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Richman, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rickoll, W')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rink, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rocchi, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rodgers, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Rogers, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Root, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ross, Joel')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ryken, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sackman, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sampen, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sandler, F')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Saucedo, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Scharrer, E')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Schauble, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Schermer, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Schultz, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Scott, Jud')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Shapiro, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Share, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sherman, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Simms, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Siu, O')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, Adam')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smith, Bryan')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Smithers, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sousa, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Spivey, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Spivey, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Stambuk, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Stirling, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Stockdale, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Strausberg, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Styer, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Sultemeier, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Swinth, Y')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tamashiro, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tanaka, T')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tanta, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tepper, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Thomas, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tiehen, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tinsley, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Toews, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tomlin, G')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Townson, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tromly, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tubert, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Tullis, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Udbye, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Utrata, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Valentine, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Van Parys, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Van Arsdel, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Vélez-Quiñones, Harry')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Walls, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Walston, V')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Ward, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warning, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warnke Flygare, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warren, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Warren, Suz')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Weinberger, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Weiss, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Weisz, C')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wesley, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wiese, N')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilbur, K')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Williams, D')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Williams, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Williams, M')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilson, Jennifer')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilson, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wilson, A')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wimberger, P')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Winkler, F')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wolf, B')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Wood, L')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Woodward, J')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Worland, R')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Zopfi, S')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Lewis, David')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($author,'Robbeloth, H')">
                                    <xsl:text>University of Puget Sound</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </institution>
                        <lname>
                            <xsl:choose>
                                <xsl:when test="contains(.,'Mc')">
                                    <xsl:variable name="post"
                                        select="substring-before(substring-after(.,'Mc'),',')"/>
                                    <xsl:text>Mc</xsl:text>
                                    <xsl:call-template name="TitleCase">
                                        <xsl:with-param name="text"
                                            select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        > </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="not(contains(.,'-'))">
                                    <xsl:call-template name="TitleCase">
                                        <xsl:with-param name="text"
                                            select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        > </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring-before(.,',')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </lname>
                        <fname>
                            <xsl:choose>
                                <!-- Removes the space after the comma that separates first and last names -->
                                <xsl:when test="contains(.,',')">
                                    <xsl:call-template name="TitleCase">
                                        <xsl:with-param name="text"
                                            select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        > </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="TitleCase">
                                        <xsl:with-param name="text"
                                            select="translate(normalize-space(substring-after(.,', ')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        > </xsl:with-param>
                                    </xsl:call-template>
                                    <!-- Otherwise, just put the author data in the contributor field -->
                                </xsl:otherwise>
                            </xsl:choose>
                        </fname>
                    </author>
                </xsl:for-each>

                <!-- Other Contributors are not included -->
            </authors>

            <!-- Disciplines not included -->

            <!-- Keywords Field -->
            <keywords>
                <xsl:for-each select="k1">
                    <keyword>
                        <!-- subject element with the qualifier "keyword" -->
                        <xsl:value-of select="lower-case(.)"/>
                        <!-- make all letters lowercase* -->
                    </keyword>
                </xsl:for-each>
            </keywords>

            <!-- Abstract field with standard text if there isn't one -->
            <abstract>
                <p>
                    <!-- package as a description element with the qualifier attribute as "abstract" -->
                    <xsl:choose>
                        <xsl:when test="ab">
                            <xsl:choose>
                                <!-- remove any wonky bits in the abstract (replaces xml characters as well) -->
                                <xsl:when test="contains(ab, '(C)')">
                                    <!-- Replaces special characters for quotes and dumps copyright statements on the end of abstracts-->
                                    <xsl:for-each
                                        select="substring-before(replace(replace(replace(replace(ab, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;gt;', '&gt;'), '&amp;amp;', $amper), '(C)')">
                                        <xsl:call-template name="globalReplace">
                                            <xsl:with-param name="outputString" select="."/>
                                            <xsl:with-param name="target" select="'            '"/>
                                            <xsl:with-param name="replacement" select="' '"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="contains(ab, 'Â©')">
                                    <!-- Replaces special characters for quotes and dumps copyright statements on the end of abstracts-->
                                    <xsl:for-each
                                        select="substring-before(replace(replace(replace(replace(ab, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;gt;', '&gt;'), '&amp;amp;', $amper), 'Â©')">
                                        <xsl:call-template name="globalReplace">
                                            <xsl:with-param name="outputString" select="."/>
                                            <xsl:with-param name="target" select="'            '"/>
                                            <xsl:with-param name="replacement" select="' '"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="contains(ab, '[ABSTRACT FROM AUTHOR]; Copyright')">
                                    <!-- Replaces special characters for quotes and dumps copyright statements on the end of abstracts-->
                                    <xsl:for-each
                                        select="substring-before(replace(replace(replace(replace(ab, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;gt;', '&gt;'), '&amp;amp;', $amper), '[ABSTRACT FROM AUTHOR]; Copyright')">
                                        <xsl:call-template name="globalReplace">
                                            <xsl:with-param name="outputString" select="."/>
                                            <xsl:with-param name="target" select="'            '"/>
                                            <xsl:with-param name="replacement" select="' '"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="contains(ab, 'ABSTRACT FROM AUTHOR]; Copyright')">
                                    <!-- Replaces special characters for quotes and dumps copyright statements on the end of abstracts-->
                                    <xsl:for-each
                                        select="substring-before(replace(replace(replace(replace(ab, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;gt;', '&gt;'), '&amp;amp;', $amper), 'ABSTRACT FROM AUTHOR]; Copyright')">
                                        <xsl:call-template name="globalReplace">
                                            <xsl:with-param name="outputString" select="."/>
                                            <xsl:with-param name="target" select="'            '"/>
                                            <xsl:with-param name="replacement" select="' '"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="contains(ab, 'Copyright')">
                                    <!-- Replaces special characters for quotes and dumps copyright statements on the end of abstracts-->
                                    <xsl:for-each
                                        select="substring-before(replace(replace(replace(replace(ab, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;gt;', '&gt;'), '&amp;amp;', $amper), 'Copyright')">
                                        <xsl:call-template name="globalReplace">
                                            <xsl:with-param name="outputString" select="."/>
                                            <xsl:with-param name="target" select="'            '"/>
                                            <xsl:with-param name="replacement" select="' '"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- otherwise, just replace the xml characters -->
                                    <xsl:for-each
                                        select="replace(replace(replace(replace(ab, '&amp;#39;',$squote), '&amp;quot;', $dquote), '&amp;gt;', '&gt;'), '&amp;amp;', $amper)">
                                        <xsl:call-template name="globalReplace">
                                            <xsl:with-param name="outputString" select="."/>
                                            <xsl:with-param name="target" select="'            '"/>
                                            <xsl:with-param name="replacement" select="' '"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- if there is no element <ab>, then there is no abstract-->
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </abstract>

            <!-- Full text url - used source_full_text instead -->

            <!-- Take document type from Refworks and transform it properly -->
            <document-type>
                <xsl:if test="rt">
                    <xsl:choose>
                        <xsl:when test="contains(rt,'Book, Whole')">
                            <xsl:text>book</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(rt,'Book, Section')">
                            <xsl:text>chapter</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(rt,'Conference Proceedings')">
                            <xsl:text>conference</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(rt,'Video')">
                            <xsl:text>presentation</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="key">
                                <xsl:for-each select="k1">
                                    <xsl:value-of select="."/>
                                    <xsl:text> </xsl:text>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="contains($key,'BOOKS -- Reviews')">
                                    <xsl:text>review</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(sf,'DT: Book Review')">
                                    <xsl:text>review</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(sf,'DT: Meeting Abstract')">
                                    <xsl:text>conference</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>article</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <!-- package as a type element with the qualifier "none" and the value "article" -->
            </document-type>

            <!-- Department -->
            <department>
                <xsl:variable name="dep">
                    <!-- Make our list of authors a variable so we can case-correct -->
                    <xsl:for-each select="a1">
                        <xsl:choose>
                            <!-- Adds a space after the comma that seperates first and last names -->
                            <xsl:when test="contains(.,',')">
                                <xsl:variable name="last">
                                    <xsl:choose>
                                        <xsl:when test="contains(.,'Mc')">
                                            <xsl:variable name="post"
                                                select="substring-before(substring-after(.,'Mc'),',')"/>
                                            <xsl:text>Mc</xsl:text>
                                            <xsl:call-template name="TitleCase">
                                                <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                > </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="not(contains(.,'-'))">
                                            <xsl:call-template name="TitleCase">
                                                <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                > </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="substring-before(.,',')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="first">
                                    <xsl:call-template name="TitleCase">
                                        <xsl:with-param name="text"
                                            select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        > </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:value-of select="concat($last,', ',$first)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>; </xsl:text>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($dep,'Firman, P')">
                        <xsl:text>Collins Memorial Library</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kueter, A')">
                        <xsl:text>Collins Memorial Library</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ricigliano, L')">
                        <xsl:text>Collins Memorial Library</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Carlin, J')">
                        <xsl:text>Collins Memorial Library</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Robbeloth, H')">
                        <xsl:text>Collins Memorial Library</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Brown, G')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Adam, J')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Allen, R')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Anderson-Connolly, R')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Andresen, D')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Austin, G')">
                        <xsl:text>Religion</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Barkin, G')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Barry, W')">
                        <xsl:text>Classics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Bartanen, K')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Bates, B')">
                        <xsl:text>Physics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Beardsley, W')">
                        <xsl:text>Philosophy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Beck, T')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Beezer, R')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Benard, E')">
                        <xsl:text>Asian Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Benveniste, M')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Berg, L')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Bernhard, J')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Beyer, T')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Billings, B')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Block, G')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Bodine, S')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Boisvert, L')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Bowen, S')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Boyles, R')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Breitenbach, W')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Bristow, N')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Brody, N')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Buescher, D')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Burgard, D')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Burnett, R')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Burnett, K')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Burns, N')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Butcher, A')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Cannon, D')">
                        <xsl:text>Philosophy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Carotenuto, G')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Christensen, C')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Christie, T')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Christoph, J')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Claire, L')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Clark, C')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Clark, K')">
                        <xsl:text>Geology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Colbert-White, E')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Colosimo, J')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Conner, B')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Crane, J')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Curley, M')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'DeHart, M')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Delos, Mi')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Demarais, A')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Demotts, R')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Despres, D')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Dillman, B')">
                        <xsl:text>International Political Economy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Dove, W')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Doyle, S')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Edwards, H')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Elliott, G')">
                        <xsl:text>Physics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Elliott, J')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Erickson, K')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Erving, G')">
                        <xsl:text>Humanities</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Evans, Ja')">
                        <xsl:text>Science, Technology and Society</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ferrari, L')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Fields, K')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Fisher, A')">
                        <xsl:text>Science, Technology and Society</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Folsom, G')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Fox-Dobbs, K')">
                        <xsl:text>Geology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Freeman, Sa')">
                        <xsl:text>Theatre Arts</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Fry, P')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Galvan, M')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Gardner, A')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Garratt, R')">
                        <xsl:text>Humanities</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Gast, B')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Gibson, C')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Glover, D')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Goldstein, B')">
                        <xsl:text>Geology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Gordon, D')">
                        <xsl:text>African American Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Grinstead, J')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Grunberg, L')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Gunderson, C')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Gurel-Atay, E')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hackett, A')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hale, C')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hale, A')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Haltom, W')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hamel, F')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hands, D')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hannaford, S')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hanson, J')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hanson, D')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Harpring, M')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Harris, P')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hastings, J')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Heavin, S')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hodum, P')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Holland, S')">
                        <xsl:text>Religion</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hommel, C')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hong, Z')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hooper, Ken')">
                        <xsl:text>Humanities</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Houston, R')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Howard, P')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hoyt, T')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hulbert, D')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hull, D')">
                        <xsl:text>Asian Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Hutchinson, R')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Imbrigotta, K')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ingalls, M')">
                        <xsl:text>Religion</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Irvin, D')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Isaacson, S')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Jackson, M')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Jacobson, Rob')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'James, An')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Jasinski, J')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Johnson, K')">
                        <xsl:text>Science, Technology and Society</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Johnson, Mi')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Johnson, L')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Johnson, G')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Jones, A')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Joshi, P')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kaminsky, T')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kay, J')">
                        <xsl:text>Religion</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Keene, D')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kelley, D')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kessel, A')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kim, Ju')">
                        <xsl:text>Exercise Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'King, J')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kirchner, G')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kirkpatrick, B')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Knoop, T')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Koelling, V')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kontogeorgopoulos, N')">
                        <xsl:text>International Political Economy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kotsis, K')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kowalski, C')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Krause, A')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Krueger, P')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kukreja, S')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Kupinse, W')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Lago-Grana, J')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Lamb, Ma')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Latimer, D')">
                        <xsl:text>Physics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Lear, J')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Lehmann, K')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Leuchtenberger, J')">
                        <xsl:text>Asian Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Lewin, B')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Linauts, M')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Livingston, G')">
                        <xsl:text>African American Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Livingston, L')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Loeb, P')">
                        <xsl:text>Philosophy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Looper, J')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ludden, M')">
                        <xsl:text>Asian Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ly, P')">
                        <xsl:text>International Political Economy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Macbain, T')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Madlung, A')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Mahato, M')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Mann, B')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Marcavage, J')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Martin, Mark')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Massey, M')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Matthews, Je')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Matthews, R')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'McCall, G')">
                        <xsl:text>Exercise Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'McCullough, J')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'McMillian, D')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'McNulty-Wooster, P')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Melchior, A')">
                        <xsl:text>Classics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Mifflin, A')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Milam, G')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Monaco, A')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Moore, S')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Moore, Da')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Morris, G')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Morse, L')">
                        <xsl:text>Classics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Mulhausen, N')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Murphy, K')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Murphy, H')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Myhre, C')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Nealey-Moore, J')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Nelson, Jen')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Neshyba, S')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Nowak, M')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Nunn, E')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Odegard, A')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Olney, M')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'eil, P')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Orechia, M')">
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Orlin, E')">
                        <xsl:text>Classics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Orloff, H')">
                        <xsl:text>Exercise Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ostrom, H')">
                        <xsl:text>African American Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Owen, A')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Owen, Sus')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Padula, D')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Paradise, A')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Paterson, E')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Peine, E')">
                        <xsl:text>International Political Economy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Perret, A')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Perret, S')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Perry, Lo Sun')">
                        <xsl:text>Asian Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Pickard, M')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Preszler, J')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Proehl, G')">
                        <xsl:text>Theatre Arts</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Pugh, M')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Putnam, A')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rafanelli, P')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ramakrishnan, S')">
                        <xsl:text>Neuroscience</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ramee, J')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ramirez Dueker, A')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Reich, J')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Reinitz, M')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Requiro, D')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rex, A')">
                        <xsl:text>Physics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rice, D')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Richards, B')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Richman, E')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rickoll, W')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rink, S')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rocchi, M')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rodgers, S')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Rogers, B')">
                        <xsl:text>Classics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Root, J')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ross, Joel')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ryken, A')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Sackman, D')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Sampen, M')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Sandler, F')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Saucedo, L')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Scharrer, E')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Schauble, R')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Schermer, S')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Schultz, R')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Scott, Jud')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Shapiro, S')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Share, D')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Sherman, D')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Simms, R')">
                        <xsl:text>African American Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Siu, O')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Smith, J')">
                        <xsl:text>Theatre Arts</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Smith, D')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Smith, K')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Smith, Adam')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Smith, Bryan')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Smithers, S')">
                        <xsl:text>Religion</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Sousa, D')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Spivey, A')">
                        <xsl:text>Physics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Spivey, M')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Stambuk, T')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Stirling, K')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Stockdale, J')">
                        <xsl:text>Religion</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Strausberg, L')">
                        <xsl:text>Chemistry</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Styer, S')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Sultemeier, D')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Swinth, Y')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tamashiro, J')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tanaka, T')">
                        <xsl:text>Physics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tanta, K')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tepper, J')">
                        <xsl:text>Geology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Thomas, R')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tiehen, J')">
                        <xsl:text>Philosophy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tinsley, D')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Toews, C')">
                        <xsl:text>Mathematics and Computer Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tomlin, G')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Townson, K')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tromly, B')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tubert, A')">
                        <xsl:text>Philosophy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Tullis, A')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Udbye, A')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Utrata, J')">
                        <xsl:text>Sociology &amp; Anthropology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Valentine, M')">
                        <xsl:text>Geology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Van Parys, D')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Vélez-Quiñones, Harry')">
                        <xsl:text>Foreign Languages and Literature</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Walls, K')">
                        <xsl:text>Theatre Arts</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Walston, V')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Ward, K')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Warning, M')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Warnke Flygare, K')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Warren, B')">
                        <xsl:text>Exercise Science</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Warren, Suz')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Weinberger, S')">
                        <xsl:text>Politics and Government</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Weiss, S')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Weisz, C')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wesley, J')">
                        <xsl:text>English</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wiese, N')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wilbur, K')">
                        <xsl:text>Occupational Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Williams, D')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Williams, L')">
                        <xsl:text>Art</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Williams, M')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wilson, Jennifer')">
                        <xsl:text>History</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wilson, P')">
                        <xsl:text>Business and Leadership</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wilson, A')">
                        <xsl:text>Physical Therapy</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wimberger, P')">
                        <xsl:text>Biology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Winkler, F')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wolf, B')">
                        <xsl:text>Communication Studies</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Wood, L')">
                        <xsl:text>Psychology</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Woodward, J')">
                        <xsl:text>Education</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Worland, R')">
                        <xsl:text>Physics</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Zopfi, S')">
                        <xsl:text>Music</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains($dep,'Lewis, D')">
                        <xsl:text>Economics</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Physical Education</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>

            </department>

            <!-- Fields-->
            <fields>
                <!-- Publication title; assumes the source publication was a Journal -->
                <xsl:if test="jf">
                    <field type="string" name="source_publication">
                        <value>
                            <!-- releation element with the qualifier "journal" -->
                            <!-- Calls template to translate into proper case -->
                            <xsl:call-template name="TitleCase">
                                <xsl:with-param name="text"
                                    select="translate(normalize-space($Journal), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                />
                            </xsl:call-template>
                        </value>
                    </field>
                </xsl:if>

                <!-- Conference or Event* -->
                <xsl:choose>
                    <xsl:when test="contains(rt,'Conference')">
                        <field type="string" name="conf_event">
                            <value>
                                <xsl:value-of select="t2"/>
                            </value>
                        </field>
                    </xsl:when>
                </xsl:choose>

                <!-- Multimedia url is not needed -->

                <!-- Multimedia format is required; this is the default choice during upload -->
                <field type="string" name="multimedia_format">
                    <value>
                        <xsl:text>flash_audio</xsl:text>
                    </value>
                </field>

                <!-- Volume number, if available -->
                <xsl:if test="vo">
                    <field type="string" name="volnum">
                        <value>
                            <!-- identifier element with the qualifier "volume" -->
                            <xsl:value-of
                                select="translate(vo, translate(vo, '1234567890', ''), '')"/>
                            <!-- only takes the numbers? -->
                        </value>
                    </field>
                </xsl:if>

                <!-- Issue number, if available -->
                <xsl:if test="is">
                    <field type="string" name="issnum">
                        <value>
                            <!-- identifier element with the qualifier "issue" -->
                            <xsl:value-of
                                select="translate(is, translate(is, '1234567890', ''), '')"/>
                            <!-- only takes the numbers? -->
                        </value>
                    </field>
                </xsl:if>

                <!-- Start and end page numbers, if present -->
                <xsl:choose>
                    <xsl:when test="sp">
                        <field type="string" name="pp">
                            <value>
                                <xsl:if test="sp">
                                    <xsl:if test="not(contains(sp,'DOI'))">
                                        <xsl:if test="not(contains(sp,'10.10'))">
                                            <xsl:value-of
                                                select="translate(sp, translate(sp, '1234567890', ''), '')"
                                            />
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:if>
                                <xsl:if test="op">
                                    <xsl:text>-</xsl:text>
                                    <xsl:apply-templates select="op"/>
                                </xsl:if>
                            </value>
                        </field>
                    </xsl:when>
                </xsl:choose>

                <!-- ISSN field - needed for checking SHERPA/RoMEO with Stephen X. Flynn's script-->
                <xsl:if test="sn">
                    <field type="string" name="issn_num">
                        <value>
                            <xsl:choose>
                                <xsl:when test="contains(sn,';')">
                                    <!-- Ignore essns -->
                                    <xsl:value-of select="substring-before(sn,';')"/>
                                </xsl:when>
                                <xsl:when test="contains(sn,',')">
                                    <!-- Ignore essns -->
                                    <xsl:value-of select="substring-before(sn,',')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="sn"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </value>
                    </field>
                </xsl:if>

                <!-- DOI field
                        DOI attempting to create good URLs no matter what format the DOI is written in (1. http://...2. /##/###, 3. :/##,###)-->
                <xsl:if test="do">
                    <field type="string" name="doi_link">
                        <value>
                            <!-- package as a relation element with the qualifier attribute "uri" -->
                            <xsl:choose>
                                <xsl:when test="contains(do,'http')">
                                    <!-- if the http declaration is included, remove any trailing white space -->
                                    <xsl:choose>
                                        <xsl:when test="contains(do,' ')">
                                            <xsl:value-of select="substring-before(do,' ')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="do"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>http://dx.doi.org/</xsl:text>
                                    <!-- otherwise use a new text node to add the doi specification,
                                                                    and pull out wonky colons -->
                                    <xsl:choose>
                                        <xsl:when test="contains(do,' ')">
                                            <xsl:choose>
                                                <xsl:when test="contains(do,':')">
                                                  <xsl:value-of
                                                  select="substring-before(substring-after(do,':'), ' ')"
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(do,' ')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:choose>
                                                <xsl:when test="contains(do,':')">
                                                  <xsl:value-of
                                                  select="substring-before(substring-after(do,':'), ' ')"
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="do"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </value>
                    </field>
                </xsl:if>

                <!-- No worldcat link; need to add later -->

                <!-- Provider Link uses the same format as the full text url -->
                <xsl:if test="lk">
                    <field type="string" name="provider_link">
                        <value>
                            <xsl:choose>
                                <xsl:when test="contains(lk,';')">
                                    <xsl:value-of select="substring-before(lk,';')"/>
                                    <!-- Only use the first link -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="lk"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </value>
                    </field>
                </xsl:if>

                <!-- Create the citation for the article -->
                <xsl:choose>
                    <xsl:when test="contains(rt,'ook')">
                        <field type="string" name="custom_citation">
                            <value>
                                <xsl:choose>
                                    <!-- author formatting -->
                                    <xsl:when test="count(a1)&gt;4">
                                        <xsl:for-each select="a1">
                                            <xsl:choose>
                                                <xsl:when test="position() = 1">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($last,', ',$first)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="position()&lt;5">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($first,' ',$last)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != 4">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:for-each>
                                        <xsl:text>, et al</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="count(a1)&lt;5">
                                        <xsl:choose>
                                            <xsl:when test="count(a1)&gt;1">
                                                <xsl:for-each select="a1">
                                                  <xsl:if test="position() = last()">
                                                  <xsl:text>and </xsl:text>
                                                  </xsl:if>
                                                  <xsl:choose>
                                                  <xsl:when test="position() = 1">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($last,', ',$first)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($first,' ',$last)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:for-each select="a1">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($last,', ',$first)"/>
                                                </xsl:for-each>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:text>. </xsl:text>
                                <xsl:value-of select="$Title"/>
                                <!-- title of the book -->
                                <xsl:text>. </xsl:text>
                                <xsl:if test="pp">
                                    <!-- publisher's location -->
                                    <xsl:value-of select="pp"/>
                                    <xsl:text>: </xsl:text>
                                </xsl:if>
                                <xsl:if test="pb">
                                    <!-- publisher -->
                                    <xsl:value-of select="$Publisher"/>
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <xsl:if test="yr">
                                    <!-- year -->
                                    <xsl:apply-templates select="yr"/>
                                    <xsl:text>. </xsl:text>
                                </xsl:if>
                            </value>
                        </field>
                    </xsl:when>
                    <xsl:otherwise>
                        <field type="string" name="custom_citation">
                            <value>
                                <xsl:choose>
                                    <!-- format the author list; includes "et al." if more than four authors -->
                                    <xsl:when test="count(a1)&gt;4">
                                        <xsl:for-each select="a1">
                                            <xsl:choose>
                                                <xsl:when test="position() = 1">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($last,', ',$first)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="position()&lt;5">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($first,' ',$last)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != 4">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:for-each>
                                        <xsl:text>, et al</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="count(a1)&lt;5">
                                        <xsl:choose>
                                            <xsl:when test="count(a1)&gt;1">
                                                <xsl:for-each select="a1">
                                                  <xsl:if test="position() = last()">
                                                  <xsl:text>and </xsl:text>
                                                  </xsl:if>
                                                  <xsl:choose>
                                                  <xsl:when test="position() = 1">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($last,', ',$first)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>

                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($first,' ',$last)"/>
                                                  <!-- Add a comma unless it's the last author -->
                                                  <xsl:if test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:for-each select="a1">
                                                  <xsl:variable name="last">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(.,'Mc')">
                                                  <xsl:variable name="post"
                                                  select="substring-before(substring-after(.,'Mc'),',')"/>
                                                  <xsl:text>Mc</xsl:text>
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space($post), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:when test="not(contains(.,'-'))">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-before(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(.,',')"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:variable>
                                                  <xsl:variable name="first">
                                                  <xsl:call-template name="TitleCase">
                                                  <xsl:with-param name="text"
                                                  select="translate(normalize-space(substring-after(.,',')), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                                  > </xsl:with-param>
                                                  </xsl:call-template>
                                                  </xsl:variable>
                                                  <xsl:value-of select="concat($last,', ',$first)"/>
                                                </xsl:for-each>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:text>. </xsl:text>
                                <!-- add a period -->
                                <xsl:if test="yr">
                                    <!-- add the year -->
                                    <xsl:apply-templates select="yr"/>
                                    <xsl:text>. </xsl:text>
                                    <!-- add a period -->
                                </xsl:if>
                                <xsl:text>"</xsl:text>
                                <!-- title begins with quotation mark -->
                                <!-- Case correct Title-->
                                <xsl:value-of select="$Title"/>
                                <!-- use the title made before, then end quotation marks -->
                                <!--  <xsl:call-template name="TitleCase">  
                            <xsl:with-param name="text" select="translate(normalize-space($Title), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>  
                            </xsl:call-template> -->
                                <xsl:text>." </xsl:text>
                                <xsl:if test="jf">
                                    <!-- add the journal -->
                                    <!-- Case correct Journal-->
                                    <xsl:call-template name="TitleCase">
                                        <xsl:with-param name="text"
                                            select="translate(normalize-space($Journal), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                        />
                                    </xsl:call-template>
                                </xsl:if>
                                <xsl:if test="vo">
                                    <!-- add the volume -->
                                    <xsl:text> </xsl:text>
                                    <xsl:apply-templates select="vo"/>
                                    <xsl:if test="is">
                                        <xsl:text>(</xsl:text>
                                        <xsl:apply-templates select="is"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:if>
                                </xsl:if>
                                <!-- Add start and end page if present (sp and op) -->
                                <xsl:if test="sp">
                                    <xsl:text>: </xsl:text>
                                    <xsl:if test="not(contains(sp,'DOI'))">
                                        <xsl:if test="not(contains(sp,'10.10'))">
                                            <xsl:value-of
                                                select="translate(sp, translate(sp, '1234567890', ''), '')"
                                            />
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:if>
                                <xsl:if test="op">
                                    <xsl:text>-</xsl:text>
                                    <xsl:apply-templates select="op"/>
                                </xsl:if>
                                <xsl:if test="jf">
                                    <!--redundant use of jf to correctly place the last period -->
                                    <xsl:text>.</xsl:text>
                                </xsl:if>
                            </value>
                        </field>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- Let BePress do the open URL since the articles were published-->
                <field type="boolean" name="create_openurl">
                    <value>
                        <xsl:choose>
                            <xsl:when test="contains(rt,'Journal Article')">yes</xsl:when>
                            <xsl:otherwise>no</xsl:otherwise>
                        </xsl:choose>
                    </value>
                </field>

                <!-- Source full text url is what appears on user end -->
                <xsl:if test="do">
                    <field type="string" name="source_fulltext_url">
                        <value>
                            <!-- package as a relation element with the qualifier attribute "uri" -->
                            <xsl:choose>
                                <xsl:when test="contains(do,'http')">
                                    <!-- if the http declaration is included, remove any trailing white space, then call it good -->
                                    <xsl:choose>
                                        <xsl:when test="contains(do,' ')">
                                            <xsl:value-of select="substring-before(do,' ')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="do"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>http://dx.doi.org/</xsl:text>
                                    <!-- otherwise use a new text node to add the doi specification,
                                                                    and pull out wonky colons -->
                                    <xsl:choose>
                                        <xsl:when test="contains(do,' ')">
                                            <xsl:choose>
                                                <xsl:when test="contains(do,':')">
                                                  <xsl:value-of
                                                  select="substring-before(substring-after(do,':'), ' ')"
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="substring-before(do,' ')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:choose>
                                                <xsl:when test="contains(do,':')">
                                                  <xsl:value-of
                                                  select="substring-before(substring-after(do,':'), ' ')"
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="do"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </value>
                    </field>
                </xsl:if>

            </fields>
        </document>

    </xsl:template>

    <!-- Template for translating into Title Case -->
    <xsl:template name="TitleCase">
        <xsl:param name="text"/>
        <xsl:param name="lastletter" select="' '"/>
        <xsl:if test="$text">
            <xsl:variable name="thisletter" select="substring($text,1,1)"/>
            <xsl:choose>
                <xsl:when test="$lastletter=' '">
                    <xsl:value-of
                        select="translate($thisletter,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$thisletter"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="TitleCase">
                <xsl:with-param name="text" select="substring($text,2)"/>
                <xsl:with-param name="lastletter" select="$thisletter"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Template that attempts to remove extra spaces in abstracts -->
    <xsl:template name="globalReplace">
        <xsl:param name="outputString"/>
        <xsl:param name="target"/>
        <xsl:param name="replacement"/>
        <xsl:choose>
            <xsl:when test="contains($outputString,$target)">
                <xsl:value-of
                    select="concat(substring-before($outputString,$target),
                    $replacement)"/>
                <xsl:call-template name="globalReplace">
                    <xsl:with-param name="outputString"
                        select="substring-after($outputString,$target)"/>
                    <xsl:with-param name="target" select="$target"/>
                    <xsl:with-param name="replacement" select="$replacement"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$outputString"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
