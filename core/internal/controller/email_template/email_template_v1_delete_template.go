package email_template

import (
	"context"
	"xenixmail-core/internal/consts"
	"xenixmail-core/internal/service/email_template"
	"xenixmail-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"

	"xenixmail-core/api/email_template/v1"
)

func (c *ControllerV1) DeleteTemplate(ctx context.Context, req *v1.DeleteTemplateReq) (res *v1.DeleteTemplateRes, err error) {
	res = &v1.DeleteTemplateRes{}

	template, _ := email_template.GetTemplate(ctx, req.Id)

	err = email_template.DeleteTemplate(ctx, req.Id)
	if err != nil {
		res.Code = 500
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to delete template")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Template,
		Log:  "Delete template :" + template.TempName + " successfully",
		Data: template,
	})

	res.SetSuccess(public.LangCtx(ctx, "Template deleted successfully"))
	return
}
