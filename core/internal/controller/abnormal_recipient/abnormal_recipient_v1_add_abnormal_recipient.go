package abnormal_recipient

import (
	"context"
	"github.com/gogf/gf/v2/errors/gerror"
	"strings"
	"xenixmail-core/api/abnormal_recipient/v1"
	"xenixmail-core/internal/consts"
	"xenixmail-core/internal/service/abnormal_recipient"
	"xenixmail-core/internal/service/public"
)

func (c *ControllerV1) AddAbnormalRecipient(ctx context.Context, req *v1.AddAbnormalRecipientReq) (res *v1.AddAbnormalRecipientRes, err error) {
	res = &v1.AddAbnormalRecipientRes{}

	recipient := strings.TrimSpace(req.Recipient)

	err = abnormal_recipient.Add(ctx, recipient)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to add exception recipient: {}", err.Error())))
		return
	}
	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.AbnormalRecipient,
		Log:  "Add abnormal recipient :" + recipient + " successfully",
		Data: recipient,
	})

	res.SetSuccess(public.LangCtx(ctx, "The exception recipient was added successfully"))
	return
}
