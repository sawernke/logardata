<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="xs syriaca functx saxon" version="2.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:syriaca="http://syriaca.org"
    xmlns:saxon="http://saxon.sf.net/" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:functx="http://www.functx.com"
    xmlns:xml="http://www.w3.org/XML/1998/namespace">
        
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" />
   
    <xsl:function name="syriaca:normalizeYear" as="xs:string">
        <!-- The spreadsheet presents years normally, but datable attributes need 4-digit years -->
        <xsl:param name="year" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($year,'-')">
                <xsl:value-of select="concat('-',syriaca:normalizeYear(substring($year,2)))"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($year) &gt; 3">
                        <xsl:value-of select="$year"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="syriaca:normalizeYear(concat('0',$year))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="syriaca:custom-dates" as="xs:date">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="trim-date" select="normalize-space($date)"/>
        <xsl:choose>
            <xsl:when test="starts-with($trim-date,'0000') and string-length($trim-date) eq 4"><xsl:text>0001-01-01</xsl:text></xsl:when>
            <xsl:when test="string-length($trim-date) eq 4"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 5"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 5"><xsl:value-of select="concat($trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 7"><xsl:value-of select="concat($trim-date,'-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 3"><xsl:value-of select="concat('0',$trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 2"><xsl:value-of select="concat('00',$trim-date,'-01-01')"/></xsl:when>
            <xsl:when test="string-length($trim-date) eq 1"><xsl:value-of select="concat('000',$trim-date,'-01-01')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$trim-date"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/root">
        <!-- [not(starts-with(SRP_ID,'F'))] -->
        <xsl:for-each select="row">
            <!-- Record ID -->
            <xsl:variable name="record-id" select="position()"/>
            
            <!-- Creates a variable containing the path of the file that should be created for this record. -->
            <xsl:variable name="filename" select="concat('../data/places/tei/',$record-id,'.xml')"/>
            <xsl:if test="Name_reduccion_standardized_both_parts != ''">
            <xsl:result-document href="{$filename}" format="xml">
                <!--
                <xsl:processing-instruction name="xml-model">
                    <xsl:text>href="http://syriaca.org/documentation/syriaca-tei-main.rnc" type="application/relax-ng-compact-syntax"</xsl:text>
                </xsl:processing-instruction>
                -->
                <TEI xml:lang="en" xmlns="http://www.tei-c.org/ns/1.0">
                    <!-- Adds header -->
                    <xsl:call-template name="header">
                        <xsl:with-param name="record-id" select="$record-id"/>
                    </xsl:call-template>
                    <text>
                        <body>
                            <listPlace>
                                <!-- NOTE: question place-type? controlled vocabulary   source=""  type="town"-->
                                <place>
                                    <xsl:attribute name="xml:id" select="concat('place-', $record-id)"/>
                                    <xsl:attribute name="source" select="concat('bib', $record-id, '-1')"/>
                                    <xsl:for-each select="Name_reduccion_standardized_both_parts[. != '']">
                                        <!-- NOTE blank placeName nodes in original run, see Andamarca for an example  -->    
                                        <placeName full="yes" type="standardized"><xsl:attribute name="xml:id" select="concat('name', $record-id, '-1')"/><xsl:value-of select="."/></placeName>    
                                    </xsl:for-each>
                                    <!-- Spanish name -->
                                    <xsl:for-each select="Name_reduccion_standardized_S_part[. != '']">
                                        <placeName type="standardized-Spanish"><xsl:attribute name="xml:id" select="concat('name', $record-id, '-2')"/><xsl:value-of select="."/></placeName>
                                    </xsl:for-each>
                                    <!-- Andean name -->
                                    <xsl:for-each select="Name_reduccion_standardized_A_part[. != '']">
                                        <placeName type="standardized-Andean"><xsl:attribute name="xml:id" select="concat('name', $record-id, '-3')"/><xsl:value-of select="."/></placeName>
                                    </xsl:for-each>
                                    <!-- NOTE: name as given in source -->
                                    <xsl:for-each select="Name_reduccion_as_given[. != '']">
                                        <placeName type="verbatim"><xsl:attribute name="xml:id" select="concat('name', $record-id, '-4')"/><xsl:value-of select="."/></placeName>
                                    </xsl:for-each>

                                    <!-- Nested/hierarchical place name -->
                                    <location type="ancient">
                                        <xsl:if test="Audiencia[. != '']">
                                            <region type="audiencia"><xsl:value-of select="Audiencia"/></region>    
                                        </xsl:if>
                                        <xsl:if test="Ciudad[. != '']">
                                            <region type="ciudad"><xsl:value-of select="Ciudad"/></region>
                                        </xsl:if>
                                        <xsl:if test="Corregimiento[. != '']">
                                            <region type="corregimiento"><xsl:value-of select="Corregimiento"/></region>
                                        </xsl:if>
                                        <xsl:if test="Repart1_name_standardized[. != '']">
                                            <region type="repartimiento">
                                                <placeName type="standardized" full="yes"><xsl:value-of select="Repart1_name_standardized"/></placeName>
                                                <placeName type="verbatim"><xsl:value-of select="Repart1_name_as_given"/></placeName>
                                            </region>
                                        </xsl:if>
                                        <xsl:if test="Repart2_name_standardized[. != '']">
                                            <region type="repartimiento">
                                                <placeName type="standardized" full="yes"><xsl:value-of select="Repart2_name_standardized"/></placeName>
                                                <placeName type="verbatim"><xsl:value-of select="Repart2_name_as_given"/></placeName>
                                            </region>
                                        </xsl:if>
                                        <xsl:if test="Repart3_name_standardized[. != '']">
                                            <region type="repartimiento">
                                                <placeName type="standardized" full="yes"><xsl:value-of select="Repart3_name_standardized"/></placeName>
                                                <placeName type="verbatim"><xsl:value-of select="Repart3_name_as_given"/></placeName>
                                            </region>
                                        </xsl:if>
                                        <xsl:if test="Repart4_name_standardized[. != '']">
                                            <region type="repartimiento">
                                                <placeName type="standardized" full="yes"><xsl:value-of select="Repart4_name_standardized"/></placeName>
                                                <placeName type="verbatim"><xsl:value-of select="Repart4_name_as_given"/></placeName>
                                            </region>
                                        </xsl:if>
                                        <xsl:if test="Name_reduccion_standardized_both_parts[. != '']">
                                            <settlement type="pueblo"><xsl:value-of select="Name_reduccion_standardized_both_parts"/></settlement>
                                        </xsl:if> 
                                        <!-- Should this include @source, or should the whole record place include the @source? -->
                                        <xsl:if test="Repart_notes[. != '']">
                                            <note type="repartimiento"><xsl:value-of select="normalize-space(Repart_notes)"></xsl:value-of></note>
                                        </xsl:if>
                                    </location>
                                    
                                    <!-- NOTE: Need controlled vocab for place types, can use http://syriaca.org/documentation/place-types.html as a starting point -->
                                    <xsl:if test="Mod_prov[. != '']">
                                        <location type="modern">
                                            <xsl:if test="Mod_country[. != '']">
                                                <country><xsl:value-of select="Mod_country"/></country>
                                            </xsl:if>
                                            <xsl:if test="Mod_prov[. != '']">
                                                <region type="province"><xsl:value-of select="Mod_prov"/></region>
                                            </xsl:if>
                                            <xsl:if test="Mod_dept[. != '']">
                                                <region type="department"><xsl:value-of select="Mod_dept"/></region>
                                            </xsl:if>
                                            <xsl:if test="Mod_settlmt[. != '']">
                                                <settlement type="pueblo"><xsl:value-of select="Mod_settlmt"/></settlement>
                                            </xsl:if>
                                            <xsl:if test="Notes_mod_loc[. != '']">
                                                <note type="modern-location"><xsl:value-of select="normalize-space(Notes_mod_loc)"/></note>    
                                            </xsl:if>
                                        </location>
                                    </xsl:if>
                                    
                                    <!-- is there a date? @when -->
                                    <!-- Population of the reducción town, if indicated -->
                                    <xsl:if test="Pop_reduc[. != '']">
                                        <population>    
                                            <desc><xsl:value-of select="Pop_reduc"/></desc>
                                        </population>
                                    </xsl:if>
                                    <!-- Number of tributaries in the reducción town, if indicated -->
                                    <xsl:if test="Tribs_reduc[. != '']">
                                        <population source="bib{$record-id}-1" type="tributaries">
                                            <desc><xsl:value-of select="Tribs_reduc"/></desc>
                                        </population>
                                    </xsl:if>
                                    
                                    <xsl:if test="Latdd_new[. != '']">
                                        <location type="gps">
                                            <!--<xsl:if test="Confidence != ''"><xsl:attribute name="cert" select="Confidence"/></xsl:if>-->
                                            <geo><xsl:value-of select="concat(Latdd_new,' ',Longdd_new)"/></geo>
                                        </location>
                                    </xsl:if>
                                    <xsl:if test="DMLat_new[. != '']">
                                        <location>
                                            <!--<xsl:if test="Confidence != ''"><xsl:attribute name="cert" select="Confidence"/></xsl:if>-->
                                            <geo><xsl:value-of select="concat(DMLat_new,' ',DMLonG_new)"/></geo>
                                        </location>
                                    </xsl:if>
                                    <xsl:if test="Reduccion_notes[. != '']">
                                        <note><xsl:value-of select="normalize-space(Reduccion_notes)"></xsl:value-of></note>
                                    </xsl:if>
                                    
                                    <xsl:if test="Info_source[. != '']">
                                        <bibl>
                                            <xsl:attribute name="xml:id" select="concat('bib', $record-id, '-1')"/>
                                            <title><xsl:value-of select="Info_source[. != '']"/></title>
                                            <xsl:if test="Info_source_page_number[. != '']">
                                                <citedRange unit="pp"><xsl:value-of select="Info_source_page_number"/></citedRange>
                                            </xsl:if>
                                        </bibl>
                                       <!--
                                        <xsl:choose>
                                            <xsl:when test="contains(Info_source,'Levillier 1921-26 v9')">
                                                <bibl>
                                                    <xsl:attribute name="xml:id" select="concat('bib', $record-id, '-1')"/>
                                                    <title>Gobernantes del Perú, Volume IX</title>
                                                    <author>Levilier 1925</author>
                                                    <xsl:if test="Info_source_page_number[. != '']">
                                                        <citedRange unit="pp"><xsl:value-of select="Info_source_page_number"/></citedRange>
                                                    </xsl:if>
                                                    <ptr target="http://logarandes.org/bibl/6396629"/>
                                                </bibl>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <bibl>
                                                    <xsl:attribute name="xml:id" select="concat('bib', $record-id, '-1')"/>
                                                    <title><xsl:value-of select="Info_source[. != '']"/></title>
                                                    <xsl:if test="Info_source_page_number[. != '']">
                                                        <citedRange unit="pp"><xsl:value-of select="Info_source_page_number"/></citedRange>
                                                    </xsl:if>
                                                </bibl>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        -->
                                    </xsl:if>
                                    <xsl:if test="Secondary_source[. != '']">
                                        <bibl>
                                            <xsl:attribute name="xml:id" select="concat('bib', $record-id, '-2')"/>
                                            <title><xsl:value-of select="Secondary_source"/></title>
                                            <xsl:if test="Secondary_source_page_number[. != '']">
                                                <citedRange unit="pp"><xsl:value-of select="Info_source_page_number"/></citedRange>
                                            </xsl:if>
                                        </bibl>
                                    </xsl:if>
                                    <xsl:if test="Primary_source[. != ''][not(contains(.,'Levillier 1921-26 v9'))]">
                                            <bibl>
                                                <xsl:attribute name="xml:id" select="concat('bib', $record-id, '-3')"/>
                                                <title><xsl:value-of select="Primary_source"/></title>
                                                <xsl:if test="Primary_source_folio[. != '']">
                                                    <citedRange unit="folio"><xsl:value-of select="Primary_source_folio"/></citedRange>
                                                </xsl:if>
                                            </bibl>                                            
                                    </xsl:if>
                                    <xsl:if test="Manuscript[. != '']">
                                        <msDesc>
                                            <msIdentifier><xsl:value-of select="Manuscript"/></msIdentifier>
                                            <xsl:if test="Manuscript_folio">
                                                <msPart><xsl:value-of select="Manuscript_folio"/></msPart>
                                            </xsl:if>
                                        </msDesc>
                                    </xsl:if>
                                    <!-- Logar id -->
                                    <idno type="URI">http://logarandes.org/place/<xsl:value-of select="$record-id"/></idno>
                                    <!-- Administrative notes -->
                                    <xsl:for-each select="Moved[. != ''] | Moved_by[. != ''] | Move_date[. != ''] | Move_ref[. != ''] | MR_other_notes[. != ''] | Delete_2[. != ''] | Delete_notes[. != ''] | MR_other_notes[. != '']">
                                        <note type="administrative" subtype="{name(.)}">
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </note>
                                    </xsl:for-each>

                                </place>
                            </listPlace>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="header" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:param name="record-id"/>
        <xsl:param name="bib-ids"/>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title level="a" xml:lang="es"><xsl:value-of select="Name_reduccion_standardized_both_parts"/></title>
                    <title level="m">LOGAR Linked Open Gazetteer of the Andean Region</title>
                    <sponsor>LOGAR Linked Open Gazetteer of the Andean Region</sponsor>
                    <funder>The National Endowment for the Humanities</funder>
                    <principal>Steven A. Wernke</principal>
                    <principal>Jeremy Mumford</principal>
                    <!-- Iron out editors -->
                    <editor role="creator">Steven A. Wernke</editor>
                    <editor role="creator">Jeremy Mumford</editor>
                    <!-- Iron out rsp statements--> 
                    <respStmt>
                        <resp>Editing, proofreading, data entry and revision by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#swernke">Steven A. Wernke</name>
                    </respStmt>
                    <respStmt>
                        <resp>Editing, proofreading, data entry and revision by</resp>
                        <name type="person" ref="http://syriaca.org/documentation/editors.xml#jmumford">Jeremy Mumford</name>
                    </respStmt>
                </titleStmt>
                <editionStmt>
                    <edition n="1.0"/>
                </editionStmt>
                <publicationStmt>
                    <authority>LOGAR Linked Open Gazetteer of the Andean Region</authority>
                    <idno type="URI">http://logarandes.org/place/<xsl:value-of select="$record-id"/>/tei</idno>
                    <availability>
                        <licence target="http://creativecommons.org/licenses/by/3.0/">
                            <p>Distributed under a Creative Commons Attribution 3.0 Unported License.</p>
                        </licence>
                    </availability>
                    <date>
                        <xsl:value-of select="current-date()"/>
                    </date>
                </publicationStmt>
                <sourceDesc>
                    <p>Born digital.</p>
                </sourceDesc>
            </fileDesc>
            <encodingDesc>
                <editorialDecl>
                    <p>This record created following the LOGAR guidelines. 
                        Documentation available at: <ref target="http://logarandes.org/documentation">http://logarandes.org/documentation</ref>.</p>
                </editorialDecl>
            </encodingDesc>
            <revisionDesc>
                <change who="http://syriaca.org/documentation/editors.xml#wsalesky" n="1.0"><xsl:attribute name="when" select="current-date()"/>CREATED: place record</change>
            </revisionDesc>
        </teiHeader>
    </xsl:template>
</xsl:stylesheet>
