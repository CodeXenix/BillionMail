package domains

import (
	"context"
	"github.com/gogf/gf/v2/errors/gerror"
	"xenixmail-core/api/domains/v1"
	"xenixmail-core/internal/consts"
	"xenixmail-core/internal/service/domains"
	"xenixmail-core/internal/service/public"
)

func (c *ControllerV1) ConsoleApplyCert(ctx context.Context, req *v1.ConsoleApplyCertReq) (res *v1.ConsoleApplyCertRes, err error) {
	res = &v1.ConsoleApplyCertRes{}

	err = domains.ApplyConsoleCert(ctx)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed : {}", err.Error())))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Domain,
		Log:  "Apply certificate for console successfully",
	})

	res.SetSuccess("Certificate applied successfully")
	return
}
