---
category: {{methodData.comment.atom_categary.desc}}
title: {{methodData.comment.atom_title.desc}}
---

## {{methodData.formatedTypePrefix}} {{methodData.methodSelector}} 

`{{classData.nameOfClass}}``{{methodData.comment.sourceInfo.filename}}`

{{methodData.comment.com_abstract.desc}}
{{#methodData.comment.hascom_discussion}}> {{methodData.comment.com_discussion.desc}}{{/methodData.comment.hascom_discussion}}

{{#methodData.hasArguments}}
### 参数

<table>
<tr>
<th>参数名</th>
<th>类型</th>
<th>说明</th>
</tr>
{{#methodData.formatedArguments}}<tr>
<td>{{arguVar}}</td>
<td>{{arguType}}</td>
<td>{{arguDesc}}</td>
</tr>{{/methodData.formatedArguments}}
</table>
{{/methodData.hasArguments}}

{{#methodData.hasResults}}
### 返回值

<table>
<tr>
<th>类型</th>
<th>说明</th>
</tr>
{{#methodData.formatedResults}}<tr>
<td>{{arguType}}</td>
<td>{{arguDesc}}</td>
</tr>{{/methodData.formatedResults}}
</table>
{{/methodData.hasResults}}

{{#methodData.comment.hasali_sample}}
### 示例

```
{{methodData.comment.ali_sample.desc}}
```
{{/methodData.comment.hasali_sample}}
