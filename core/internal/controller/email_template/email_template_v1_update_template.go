package email_template

import (
	"context"
	"xenixmail-core/internal/consts"
	"xenixmail-core/internal/service/email_template"
	"xenixmail-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"

	"xenixmail-core/api/email_template/v1"
)

func (c *ControllerV1) UpdateTemplate(ctx context.Context, req *v1.UpdateTemplateReq) (res *v1.UpdateTemplateRes, err error) {
	res = &v1.UpdateTemplateRes{}

	// Check if template exists
	template, err := email_template.GetTemplate(ctx, req.Id)
	if err != nil {
		res.Code = 500
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to get template")))
		return
	}
	if template == nil {
		res.Code = 400
		res.SetError(gerror.New(public.LangCtx(ctx, "Template not found")))
		return
	}

	// Update template
	err = email_template.UpdateTemplate(ctx, req.Id, req.TempName, req.Content, req.Render)
	if err != nil {
		res.Code = 500
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to update template")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Template,
		Log:  "Update template :" + req.TempName + " successfully",
		Data: req,
	})

	res.SetSuccess(public.LangCtx(ctx, "Template updated successfully"))
	return
}
