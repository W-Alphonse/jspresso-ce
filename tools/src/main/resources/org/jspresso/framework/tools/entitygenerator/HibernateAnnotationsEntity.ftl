<#macro generateClassHeader componentDescriptor>
  <#local package=componentDescriptor.name[0..componentDescriptor.name?last_index_of(".")-1]/>
  <#local componentName=componentDescriptor.name[componentDescriptor.name?last_index_of(".")+1..]/>
  <#local superInterfaceList=[]/>
  <#global isEntity=componentDescriptor.entity/>
  <#if componentDescriptor.ancestorDescriptors??>
    <#list componentDescriptor.ancestorDescriptors as ancestorDescriptor>
      <#if "org.jspresso.framework.model.entity.IEntity" != ancestorDescriptor.name>
	      <#if ancestorDescriptor.entity>
	        <#local superEntity=ancestorDescriptor/>
	        <#if superEntity.sqlName??>
	          <#local superEntityTableName=superEntity.sqlName/>
	        <#else>  
	          <#local superEntityName=superEntity.name[superEntity.name?last_index_of(".")+1..]/>
	          <#local superEntityTableName=generateSQLName(superEntityName)/>
	        </#if>
	      <#else>
          <#local superInterfaceList=superInterfaceList + [ancestorDescriptor.name]/>
	      </#if>
	    </#if>
    </#list>
    <#if isEntity && !(superEntity??)>
      <#local superInterfaceList = ["org.jspresso.framework.model.entity.IEntity"] + superInterfaceList/>
    </#if>
  </#if>
  <#if componentDescriptor.serviceContractClassNames??>
    <#list componentDescriptor.serviceContractClassNames as serviceContractClassName>
      <#local superInterfaceList=superInterfaceList + [serviceContractClassName]/>
    </#list>
  </#if>
  <#if componentDescriptor.sqlName??>
    <#global tableName=componentDescriptor.sqlName/>
  <#else>  
    <#global tableName=generateSQLName(componentName)/>
  </#if>
/*
 * Generated by Jspresso. All rights reserved.
 */
package ${package};

/**
 * ${componentName} <#if isEntity>entity<#else>component</#if>.
 * <p>
 * Generated by Jspresso. All rights reserved.
 * <p>
 * @author Generated by Jspresso
 */
  <#if isEntity>
@javax.persistence.Entity
@org.hibernate.annotations.Tuplizer(
    impl = org.jspresso.framework.model.persistence.hibernate.entity.tuplizer.DynamicPojoEntityTuplizer.class
)
@org.hibernate.annotations.Entity(
    dynamicInsert = true
  , dynamicUpdate = true
)
@javax.persistence.Inheritance(
    strategy = javax.persistence.InheritanceType.JOINED
)
    <#list componentDescriptor.declaredPropertyDescriptors as propertyDescriptor>
      <#if propertyDescriptor.unicityScope??>
        <#local propertyName=propertyDescriptor.name/>
        <#if propertyDescriptor.sqlName??>
          <#local columnName=propertyDescriptor.sqlName/>
          <#local columnNameGenerated = false/>
        <#else>  
          <#local columnName=generateSQLName(propertyName)/>
          <#local columnNameGenerated = true/>
        </#if>
        <#if uniqueConstraints??>
          <#local uniqueConstraint = uniqueConstraints[propertyDescriptor.unicityScope]/>
          <#if uniqueConstraint??>
            <#local uniqueConstraint = uniqueConstraint + [columnName]/>
          <#else>
            <#local uniqueConstraint = [columnName]/>
          </#if>
          <#local uniqueConstraints = uniqueConstraints + {propertyDescriptor.unicityScope:uniqueConstraint}/>
        <#else>
          <#local uniqueConstraints = {propertyDescriptor.unicityScope:[columnName]}/>
        </#if>
      </#if>
    </#list>

@javax.persistence.Table(
    name = "${tableName}"
    <#if uniqueConstraints??>
  , uniqueConstraints = {
      <#assign constraints = uniqueConstraints?keys/>
      <#list constraints as uniqueConstraint>
        <#if uniqueConstraint_index=0>
        @javax.persistence.UniqueConstraint(
        <#else>
      , @javax.persistence.UniqueConstraint(
        </#if>
            name = "${generateSQLName(uniqueConstraint)}_UNQ"
          , columnNames = {
          <#assign columns = uniqueConstraints[uniqueConstraint]/>
          <#list columns as column>
            <#if column_index=0>
                "${column}"
            <#else>
              , "${column}"
            </#if>
          </#list>
          }
        )
      </#list>
    }
    </#if>
)
@org.hibernate.annotations.Persister(
    impl = org.jspresso.framework.model.persistence.hibernate.entity.persister.EntityProxyJoinedSubclassEntityPersister.class
)
    <#if superEntity??>
@javax.persistence.PrimaryKeyJoinColumn(
    name = "ID"
)
    </#if>
  <#elseif componentDescriptor.purelyAbstract>
@javax.persistence.MappedSuperclass
  <#else>
@javax.persistence.Embeddable
@org.hibernate.annotations.Tuplizer(
    impl = org.jspresso.framework.model.persistence.hibernate.entity.tuplizer.DynamicPojoComponentTuplizer.class
)
  </#if>
@SuppressWarnings("all")
  <#if isEntity>
public abstract class ${componentName}<#if superEntity??> extends ${superEntity.name}</#if>
  <#else>
public interface ${componentName}
</#if>
<#if (superInterfaceList?size > 0)>
       <#if isEntity>implements<#else>extends</#if>
<#list superInterfaceList as superInterface>       ${superInterface}<#if superInterface_has_next>,${"\n"}<#else> {</#if></#list>
<#else> {
</#if>
  <#if isEntity && !superEntity??>
  <#--<#if isEntity>-->


  /**
   * {@inheritDoc}
   */
  @javax.persistence.Id
  @org.hibernate.annotations.Type(
      type = "string"
  )
  @javax.persistence.Column(
      name = "ID"
    , length = 36
  )
  public abstract java.io.Serializable getId();

  /**
   * {@inheritDoc}
   */
  @javax.persistence.Version
  @javax.persistence.Column(
    name = "VERSION"
  )
  @org.hibernate.annotations.Type(
    type = "integer"
  )
  public abstract Integer getVersion();
  </#if>

</#macro>

<#macro generateScalarSetter componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#local propertyType=propertyDescriptor.modelTypeName/>
  /**
   * Sets the ${propertyName}.
   *
   * @param ${propertyName}
   *          the ${propertyName} to set.
   */
  public abstract void set${propertyName?cap_first}(${propertyType} ${propertyName});

</#macro>

<#macro generateScalarGetter componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#local propertyType=propertyDescriptor.modelTypeName/>
  <#if propertyDescriptor.sqlName??>
    <#local columnName=propertyDescriptor.sqlName/>
    <#local columnNameGenerated = false/>
  <#else>  
    <#local columnName=generateSQLName(propertyName)/>
    <#local columnNameGenerated = true/>
  </#if>
  /**
   * Gets the ${propertyName}.
   *
   * @return the ${propertyName}.
   */
  <#if !propertyDescriptor.computed>
    <#if !propertyDescriptor.versionControl>
  @org.hibernate.annotations.OptimisticLock(
      excluded = true
  )
    </#if>
    <#if instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IDatePropertyDescriptor")>
  @org.hibernate.annotations.Type(
      <#if propertyDescriptor.type = "DATE_TIME">
    type = "timestamp"
      <#else>
    type = "date"
      </#if>
  )
    <#elseif instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.ITimePropertyDescriptor")>
  @org.hibernate.annotations.Type(
    type = "time"
  )
    </#if>
  @javax.persistence.Column(
    name = "${columnName}"
    <#if (   instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IStringPropertyDescriptor")
          || instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IEnumerationPropertyDescriptor")
          || instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IBinaryPropertyDescriptor")
         )
      && (propertyDescriptor.maxLength??)>
    , length = ${propertyDescriptor.maxLength?c}
    <#elseif instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IColorPropertyDescriptor")>
    , length = 10
    </#if>
    <#if (   propertyDescriptor.mandatory
          || instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IBooleanPropertyDescriptor"))>
    , nullable = false
    </#if>
    <#if instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.INumberPropertyDescriptor")>
      <#if (propertyDescriptor.minValue??)
         &&(propertyDescriptor.maxValue??)>
        <#local infLength=propertyDescriptor.minValue?int?c?length/>
        <#local supLength=propertyDescriptor.maxValue?int?c?length/>
        <#if (infLength > supLength)>
          <#local length=infLength/>
        <#else>
          <#local length=supLength/>
        </#if>
    , precision = ${length?c}
      <#else>
    , precision = 10
      </#if>
      <#if instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IDecimalPropertyDescriptor")>
        <#if propertyDescriptor.maxFractionDigit??>
    , scale = ${propertyDescriptor.maxFractionDigit?c}
        <#else>
    , scale = 2
        </#if>
      </#if>
    </#if>
  )
  <#if propertyDescriptor.mandatory>
  @javax.persistence.Basic(
      optional = false
  )
  </#if>
  <#elseif propertyDescriptor.sqlName??>
  @org.hibernate.annotations.Formula("${propertyDescriptor.sqlName}")
  <#else>
  @javax.persistence.Transient
  </#if>
  <#if instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IBooleanPropertyDescriptor")>
  public abstract ${propertyType} is${propertyName?cap_first}();
  <#else>
  public abstract ${propertyType} get${propertyName?cap_first}();
  </#if>

</#macro>

<#macro generateCollectionSetter componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#local collectionType=propertyDescriptor.modelTypeName/>
  <#local elementType=propertyDescriptor.referencedDescriptor.elementDescriptor.name/>
  /**
   * Sets the ${propertyName}.
   *
   * @param ${propertyName}
   *          the ${propertyName} to set.
   */
  public abstract void set${propertyName?cap_first}(${collectionType}<${elementType}> ${propertyName});

</#macro>

<#macro generateCollectionAdder componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#local elementType=propertyDescriptor.referencedDescriptor.elementDescriptor.name/>
  /**
   * Adds an element to the ${propertyName}.
   *
   * @param ${propertyName}Element
   *          the ${propertyName} element to add.
   */
  public abstract void addTo${propertyName?cap_first}(${elementType} ${propertyName}Element);
  <#if propertyDescriptor.modelTypeName = "java.util.List">

  /**
   * Adds an element to the ${propertyName} at the specified index. If the index is out
   * of the list bounds, the element is simply added at the end of the list.
   *
   * @param index
   *          the index to add the ${propertyName} element at.
   * @param ${propertyName}Element
   *          the ${propertyName} element to add.
   */
  public abstract void addTo${propertyName?cap_first}(int index, ${elementType} ${propertyName}Element);
  </#if>

</#macro>

<#macro generateCollectionRemer componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#local elementType=propertyDescriptor.referencedDescriptor.elementDescriptor.name/>
  /**
   * Removes an element from the ${propertyName}.
   *
   * @param ${propertyName}Element
   *          the ${propertyName} element to remove.
   */
  public abstract void removeFrom${propertyName?cap_first}(${elementType} ${propertyName}Element);

</#macro>

<#macro generateCollectionGetter componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#if propertyDescriptor.fkName??>
    <#local fkName=propertyDescriptor.fkName/>
  </#if>
  <#local collectionType=propertyDescriptor.modelTypeName/>
  <#local elementDescriptor=propertyDescriptor.referencedDescriptor.elementDescriptor/>
  <#local elementType=propertyDescriptor.referencedDescriptor.elementDescriptor.name/>
  <#local componentName=componentDescriptor.name[componentDescriptor.name?last_index_of(".")+1..]/>
  <#local elementName=elementType[elementType?last_index_of(".")+1..]/>
  <#local isEntity=componentDescriptor.entity/>
  <#local isElementEntity=elementDescriptor.entity/>
  <#if collectionType="java.util.List">
    <#local hibernateCollectionType="list"/>
  <#elseif collectionType="java.util.Set">
    <#local hibernateCollectionType="set"/>
  </#if>
  <#local manyToMany=propertyDescriptor.manyToMany/>
  <#if propertyDescriptor.reverseRelationEnd??>
    <#local bidirectional=true/>
    <#local reversePropertyName=propertyDescriptor.reverseRelationEnd.name/>
    <#local reverseMandatory=propertyDescriptor.reverseRelationEnd.mandatory/>
    <#if propertyDescriptor.reverseRelationEnd.fkName??>
      <#local reverseFkName=propertyDescriptor.reverseRelationEnd.fkName/>
    </#if>
    <#if manyToMany>
      <#--
      <#if (compareStrings(elementName, componentName) != 0)>
        <#local inverse=(compareStrings(elementName, componentName) > 0)/>
      <#else>
        Reflexive many to many
        <#local inverse=(compareStrings(propertyName, reversePropertyName) > 0)/>
      </#if>
      -->
      <#local inverse = !propertyDescriptor.leadingPersistence/>
    <#else>
      <#if hibernateCollectionType="list">
        <#local inverse=false/>
      <#else>
        <#local inverse=true/>
      </#if>
    </#if>
  <#else>
    <#local bidirectional=false/>
    <#local inverse=false/>
    <#if !manyToMany>
      <#local reversePropertyName=propertyName+componentName/>
    </#if>
  </#if>
  <#if componentDescriptor.sqlName??>
    <#local compSqlName=componentDescriptor.sqlName/>
  <#else>
    <#local compSqlName=generateSQLName(componentName)/>
  </#if>
  <#if elementDescriptor.sqlName??>
    <#local eltSqlName=elementDescriptor.sqlName/>
  <#else>
    <#local eltSqlName=generateSQLName(elementName)/>
  </#if>
  <#if propertyDescriptor.sqlName??>
    <#local propSqlName=propertyDescriptor.sqlName/>
    <#local propSqlNameGenerated = false/>
  <#else>
    <#local propSqlName=generateSQLName(propertyName)/>
    <#local propSqlNameGenerated = true/>
  </#if>
  <#local revSqlNameGenerated = true/>
  <#if propertyDescriptor.reverseRelationEnd??>
	  <#if propertyDescriptor.reverseRelationEnd.sqlName??>
	    <#local revSqlName=propertyDescriptor.reverseRelationEnd.sqlName/>
      <#local revSqlNameGenerated = false/>
	  <#else>
	    <#local revSqlName=generateSQLName(reversePropertyName)/>
	  </#if>
	<#else>
	  <#local revSqlName=propSqlName+"_"+compSqlName/>
	</#if>
  /**
   * Gets the ${propertyName}.
   *
   * @return the ${propertyName}.
   */
  <#if propertyDescriptor.computed>
  @javax.persistence.Transient
  <#else>
    <#if !propertyDescriptor.versionControl>
  @org.hibernate.annotations.OptimisticLock(
      excluded = true
  )
    </#if>
  @org.hibernate.annotations.Cascade(
    {
        org.hibernate.annotations.CascadeType.PERSIST
      , org.hibernate.annotations.CascadeType.MERGE
      , org.hibernate.annotations.CascadeType.SAVE_UPDATE
    <#if propertyDescriptor.composition>
      , org.hibernate.annotations.CascadeType.DELETE
    </#if>
    }
  )
  @org.hibernate.annotations.Type(
    type = "${hibernateCollectionType}"
  )
    <#if manyToMany>
      <#if !inverse>
        <#local joinTableName=compSqlName+"_"+propSqlName/>
  @javax.persistence.JoinTable(
      name = "${joinTableName}"
        <#if componentName=elementName>
    , joinColumns = @javax.persistence.JoinColumn(
        name = "${compSqlName}_ID1"
    )
    , inverseJoinColumns = @javax.persistence.JoinColumn(
        name = "${compSqlName}_ID2"
    )
        <#else>
    , joinColumns = @javax.persistence.JoinColumn(
        name = "${compSqlName}_ID"
    )
    , inverseJoinColumns = @javax.persistence.JoinColumn(
        name = "${eltSqlName}_ID"
    )
        </#if>
  )
        <#if componentName=elementName>
  @org.hibernate.annotations.ForeignKey(
          <#if fkName??>
      name = "${fkName}"
          <#else>
      name = "${joinTableName}_${compSqlName}_FK1"
          </#if>
          <#if reverseFkName??>
    , inverseName = "${reverseFkName}"
          <#else>
    , inverseName = "${joinTableName}_${compSqlName}_FK2"
          </#if>
  )
        <#else>
  @org.hibernate.annotations.ForeignKey(
          <#if fkName??>
      name = "${fkName}"
          <#else>
      name = "${joinTableName}_${compSqlName}_FK"
          </#if>
          <#if reverseFkName??>
    , inverseName = "${reverseFkName}"
          <#else>
    , inverseName = "${joinTableName}_${eltSqlName}_FK"
          </#if>
  )
        </#if>
      </#if>
  @javax.persistence.ManyToMany(
      targetEntity = ${elementType}.class
      <#if inverse>
    , mappedBy = "${reversePropertyName}"
      </#if>
  )
    <#else>
      <#if !inverse>
  @javax.persistence.JoinColumn(
        <#if revSqlNameGenerated>
      name = "${revSqlName}_ID"
        <#else>
      name = "${revSqlName}"
        </#if>
  )
        <#if fkName??>
  @org.hibernate.annotations.ForeignKey(
      name = "${fkName}"
  )
        <#else>
  @org.hibernate.annotations.ForeignKey(
      name = "${revSqlName}_FK"
  )
        </#if>
      </#if>
  @javax.persistence.OneToMany(
      targetEntity = ${elementType}.class
      <#if inverse>
    , mappedBy = "${reversePropertyName}"
      </#if>
  )
    </#if>
    <#if hibernateCollectionType="list">
  @javax.persistence.OrderColumn(
      name = "${compSqlName}_${propSqlName}_SEQ"
  )
    <#else>
  @javax.persistence.OrderBy
    </#if>
  </#if>
  public abstract ${collectionType}<${elementType}> get${propertyName?cap_first}();

</#macro>

<#macro generateEntityRefSetter componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#local propertyType=propertyDescriptor.referencedDescriptor.name/>
  /**
   * Sets the ${propertyName}.
   *
   * @param ${propertyName}
   *          the ${propertyName} to set.
   */
  public abstract void set${propertyName?cap_first}(${propertyType} ${propertyName});

</#macro>

<#macro generateComponentRefGetter componentDescriptor propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#if propertyDescriptor.fkName??>
    <#local fkName=propertyDescriptor.fkName/>
  </#if>
  <#local propertyType=propertyDescriptor.referencedDescriptor.name/>
  <#if propertyDescriptor.referencedDescriptor.sqlName??>
    <#local refSqlName=propertyDescriptor.referencedDescriptor.sqlName/>
  <#else>  
    <#local refSqlName=generateSQLName(propertyDescriptor.referencedDescriptor.name[propertyDescriptor.referencedDescriptor.name?last_index_of(".")+1..])/>
  </#if>
  <#local isReferenceEntity=propertyDescriptor.referencedDescriptor.entity/>
  <#local isPurelyAbstract=propertyDescriptor.referencedDescriptor.purelyAbstract/>
  <#local oneToOne=propertyDescriptor.oneToOne/>
  <#local composition=propertyDescriptor.composition/>
  <#if propertyDescriptor.reverseRelationEnd??>
    <#local bidirectional=true/>
    <#local reversePropertyName=propertyDescriptor.reverseRelationEnd.name/>
    <#if instanceof(propertyDescriptor.reverseRelationEnd, "org.jspresso.framework.model.descriptor.IReferencePropertyDescriptor")>
      <#local componentName=componentDescriptor.name[componentDescriptor.name?last_index_of(".")+1..]/>
      <#local elementName=propertyType[propertyType?last_index_of(".")+1..]/>
      <#--
      <#if (compareStrings(elementName, componentName) != 0)>
        <#local reverseOneToOne=(compareStrings(elementName, componentName) < 0)/>
      <#else>
        Reflexive one to one
        <#local reverseOneToOne=(compareStrings(propertyName, reversePropertyName) < 0)/>
      </#if>
      -->
      <#local reverseOneToOne = !propertyDescriptor.leadingPersistence/>
    <#else>
      <#local reverseOneToOne=false/>
      <#if propertyDescriptor.reverseRelationEnd.modelTypeName="java.util.List">
        <#local managesPersistence=false/>
      <#else>
        <#local managesPersistence=true/>
      </#if>
    </#if>
  <#else>
    <#local bidirectional=false/>
    <#local reverseOneToOne=false/>
  </#if>
  <#if propertyDescriptor.sqlName??>
    <#local propSqlName=propertyDescriptor.sqlName/>
    <#local propSqlNameGenerated = false/>
  <#else>  
    <#local propSqlName=generateSQLName(propertyName)/>
    <#local propSqlNameGenerated = true/>
  </#if>
  /**
   * Gets the ${propertyName}.
   *
   * @return the ${propertyName}.
   */
  <#if propertyDescriptor.computed>
  @javax.persistence.Transient
  <#else>
    <#if !propertyDescriptor.versionControl>
  @org.hibernate.annotations.OptimisticLock(
      excluded = true
  )
    </#if>
    <#if oneToOne || bidirectional>
  @org.hibernate.annotations.Cascade(
    {
        org.hibernate.annotations.CascadeType.PERSIST
      , org.hibernate.annotations.CascadeType.MERGE
      , org.hibernate.annotations.CascadeType.SAVE_UPDATE
      <#if propertyDescriptor.composition>
      , org.hibernate.annotations.CascadeType.DELETE
      </#if>
    }
  )
    </#if>
    <#if !oneToOne || !reverseOneToOne>
  @javax.persistence.JoinColumn(
      <#if propSqlNameGenerated>
      name = "${propSqlName}_ID"
      <#else>
      name = "${propSqlName}"
      </#if>
      <#if propertyDescriptor.mandatory>
    , nullable = false
      </#if>
  )
    </#if> 
    <#if isReferenceEntity>
      <#if oneToOne>
  @javax.persistence.OneToOne(
      targetEntity = ${propertyType}.class
        <#if reverseOneToOne>
    , mappedBy = "${propertyDescriptor.reverseRelationEnd.name}"
        <#else>
          <#if propertyDescriptor.fetchType?? && propertyDescriptor.fetchType.toString() = "JOIN">
    , fetch = javax.persistence.FetchType.EAGER
          </#if>
          <#if propertyDescriptor.mandatory>
    , optional = false
          </#if>
        </#if>
  )
      <#else>
  @javax.persistence.ManyToOne(
      targetEntity = ${propertyType}.class
  )
        <#if isEntity>
          <#if fkName??>
  @org.hibernate.annotations.ForeignKey(
      name = "${fkName}"
  )
          <#else>
  @org.hibernate.annotations.ForeignKey(
      name = "${tableName}_${propSqlName}_FK"
  )
          </#if>
        </#if>
      </#if>
    <#elseif !isPurelyAbstract>
  @javax.persistence.Embedded
  @org.hibernate.annotations.Tuplizer(
      impl = org.jspresso.framework.model.persistence.hibernate.entity.tuplizer.DynamicPojoComponentTuplizer.class
  )
  @javax.persistence.AttributeOverrides({
      <#list propertyDescriptor.referencedDescriptor.propertyDescriptors as refPropertyDescriptor>
        <#if refPropertyDescriptor.sqlName??>
          <#local refPropSqlName=refPropertyDescriptor.sqlName/>
        <#else>  
          <#local refPropSqlName=generateSQLName(refPropertyDescriptor.name)/>
        </#if>
        <#if refPropertyDescriptor_index=0>
        @javax.persistence.AttributeOverride(
            name = "${refPropertyDescriptor.name}"
          , column = @javax.persistence.Column(
                name = "${propSqlName}_${refPropSqlName}"
            )
        )
        <#else>
      , @javax.persistence.AttributeOverride(
            name = "${refPropertyDescriptor.name}"
          , column = @javax.persistence.Column(
                name = "${propSqlName}_${refPropSqlName}"
            )
        )
        </#if>
      </#list>
  })
    <#else>
  @org.hibernate.annotations.Any(
      metaColumn = @javax.persistence.Column(
          name = "${propSqlName}_NAME"
      )
      <#if propertyDescriptor.mandatory>
    , optional=false
      </#if>
  )
  @org.hibernate.annotations.AnyMetaDef (
      idType = "string"
    , metaType = "string"
  )
  @javax.persistence.JoinColumn(
      <#if propSqlNameGenerated>
      name = "${propSqlName}_ID"
      <#else>
      name = "${propSqlName}"
      </#if>
      <#if propertyDescriptor.mandatory>
    , nullable = false
      </#if>
  )
    </#if>
  </#if>
  public abstract ${propertyType} get${propertyName?cap_first}();

</#macro>

<#macro generatePropertyNameConstant propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  /**
   * Constant value for ${propertyName}.
   */
  String ${generateSQLName(propertyName)} = "${propertyName}";

</#macro>

<#macro generateEnumerationConstants propertyDescriptor>
  <#local propertyName=propertyDescriptor.name/>
  <#list propertyDescriptor.enumerationValues as enumerationValue>
  /**
   * Constant enumeration value for ${propertyName} : ${enumerationValue}.
   */
  String ${generateSQLName(propertyName + "_" + enumerationValue)} = "${enumerationValue}";

  </#list>
</#macro>

<#macro generateCollectionPropertyAccessors componentDescriptor propertyDescriptor>
  <@generatePropertyNameConstant propertyDescriptor=propertyDescriptor/>
  <@generateCollectionGetter componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  <#if propertyDescriptor.modifiable>
    <@generateCollectionSetter componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
    <@generateCollectionAdder componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
    <@generateCollectionRemer componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  </#if>

</#macro>

<#macro generateReferencePropertyAccessors componentDescriptor propertyDescriptor>
  <@generatePropertyNameConstant propertyDescriptor=propertyDescriptor/>
  <@generateComponentRefGetter componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  <#if propertyDescriptor.modifiable>
    <@generateEntityRefSetter componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  </#if>

</#macro>

<#macro generateScalarPropertyAccessors componentDescriptor propertyDescriptor>
  <@generatePropertyNameConstant propertyDescriptor=propertyDescriptor/>
  <#if instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IEnumerationPropertyDescriptor")>
    <@generateEnumerationConstants propertyDescriptor=propertyDescriptor/>
  </#if>
  <@generateScalarGetter componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  <#if propertyDescriptor.modifiable>
    <@generateScalarSetter componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  </#if>

</#macro>

<#macro generatePropertyAccessors componentDescriptor propertyDescriptor>
  <#if instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.ICollectionPropertyDescriptor")>
    <@generateCollectionPropertyAccessors componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  <#elseif instanceof(propertyDescriptor, "org.jspresso.framework.model.descriptor.IReferencePropertyDescriptor")>
    <@generateReferencePropertyAccessors componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  <#else>
    <@generateScalarPropertyAccessors componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
  </#if>

</#macro>
<@generateClassHeader componentDescriptor=componentDescriptor/>
<#if componentDescriptor.declaredPropertyDescriptors??>
  <#assign empty=true/>
  <#list componentDescriptor.declaredPropertyDescriptors as propertyDescriptor>
    <@generatePropertyAccessors componentDescriptor=componentDescriptor propertyDescriptor=propertyDescriptor/>
    <#assign empty=false/>
  </#list>
  <#if empty>
  // THIS IS JUST A MARKER INTERFACE.
  </#if>
<#else>
  // THIS IS JUST A MARKER INTERFACE.
</#if>
}
