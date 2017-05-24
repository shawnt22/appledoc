---
category: {{classData.nameOfClass}}
title: {{methodData.methodSelector}}
---

## {{methodData.formatedTypePrefix}} {{methodData.methodSelector}} `{{classData.nameOfClass}}`

{{methodData.comment.shortDescription.stringValue}}
> {{#methodData.comment.longDescription.components}}{{stringValue}}{{/methodData.comment.longDescription.components}}

{{#methodData.comment.hasMethodParameters}}
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
{{/methodData.comment.hasMethodParameters}}

{{#methodData.comment.hasMethodResult}}
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
{{/methodData.comment.hasMethodResult}}

### 示例

```
TODO
```
